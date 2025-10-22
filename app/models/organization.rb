class Organization < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User'
  has_many :organization_members, dependent: :destroy
  has_many :users, through: :organization_members
  has_many :credit_transactions, dependent: :destroy
  has_one_attached :logo

  # Constants
  MIN_DEPOSIT_AMOUNT = 10.00
  MIN_DAILY_BUDGET = 25.00

  # Stripe subscription statuses
  SUBSCRIPTION_STATUSES = %w[trialing active past_due canceled unpaid incomplete incomplete_expired].freeze
  SUBSCRIPTION_PLANS = %w[free basic pro enterprise].freeze

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :subscription_plan, inclusion: { in: SUBSCRIPTION_PLANS }, allow_nil: true
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }, allow_nil: true
  validates :credits_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :owner_id, presence: true
  validates :primary_color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true
  validates :secondary_color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? }
  after_create :set_default_plan
  after_create :add_owner_as_member
  before_destroy :cancel_stripe_subscription

  # Stripe Customer Methods
  def stripe_customer
    return nil unless stripe_customer_id
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  rescue Stripe::InvalidRequestError
    nil
  end

  def create_stripe_customer!
    return if stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: owner.email,
      name: name,
      metadata: { organization_id: id, owner_id: owner_id }
    )

    update!(stripe_customer_id: customer.id)
    customer
  end

  # Subscription Management
  def active_subscription?
    %w[trialing active].include?(subscription_status)
  end

  def subscribed?
    subscription_plan.present? && subscription_plan != 'free' && active_subscription?
  end

  def on_trial?
    subscription_status == 'trialing' && trial_ends_at.present? && trial_ends_at > Time.current
  end

  def trial_days_remaining
    return 0 unless on_trial?
    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  def plan_features
    plan_key = subscription_plan&.to_sym || :free
    STRIPE_PLANS[plan_key] || STRIPE_PLANS[:free]
  end

  def can_create_campaign?
    limit = plan_features[:features][:campaigns_limit]
    limit.nil? || Campaign.count < limit
  end

  def can_create_banner?
    limit = plan_features[:features][:banners_limit]
    limit.nil? || Banner.count < limit
  end

  def can_create_video?
    limit = plan_features[:features][:videos_limit]
    limit.nil? || BannerVideo.count < limit
  end

  # Stripe Subscription Methods
  def subscribe_to_plan!(plan_name, payment_method_id: nil)
    plan = STRIPE_PLANS[plan_name.to_sym]
    raise ArgumentError, "Invalid plan: #{plan_name}" unless plan
    raise ArgumentError, "Free plan doesn't require payment" if plan_name.to_s == 'free'

    create_stripe_customer! unless stripe_customer_id

    subscription = Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ price: plan[:stripe_price_id] }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
    )

    update!(
      stripe_subscription_id: subscription.id,
      subscription_plan: plan_name.to_s,
      subscription_status: subscription.status,
      trial_ends_at: subscription.trial_end ? Time.at(subscription.trial_end) : nil
    )

    subscription
  end

  def cancel_subscription!
    return unless stripe_subscription_id

    subscription = Stripe::Subscription.cancel(stripe_subscription_id)

    update!(
      subscription_status: 'canceled',
      stripe_subscription_id: nil
    )

    subscription
  end

  def update_subscription_status!(status)
    update!(subscription_status: status)
  end

  # Credits Management
  def add_credits(amount, description, transaction_type = CreditTransaction::DEPOSIT)
    ActiveRecord::Base.transaction do
      credit_transactions.create!(
        amount: amount,
        transaction_type: transaction_type,
        description: description
      )
      increment!(:credits_balance, amount)
    end
  end

  def deduct_credits(amount, description)
    raise ArgumentError, "Insufficient credits" if credits_balance < amount

    ActiveRecord::Base.transaction do
      credit_transactions.create!(
        amount: -amount,
        transaction_type: CreditTransaction::SPEND,
        description: description
      )
      decrement!(:credits_balance, amount)
    end
  end

  def sufficient_credits?(amount)
    credits_balance >= amount
  end

  def can_run_campaign?(daily_budget)
    daily_budget >= MIN_DAILY_BUDGET && sufficient_credits?(daily_budget)
  end

  # Member Management
  def add_member(user, role: 'member')
    organization_members.create!(user: user, role: role)
  end

  def remove_member(user)
    return false if user.id == owner_id # Can't remove owner
    organization_members.find_by(user: user)&.destroy
  end

  def member?(user)
    users.include?(user)
  end

  def role_for(user)
    organization_members.find_by(user: user)&.role
  end

  # Branding Methods
  def brand_primary_color
    primary_color.presence || '#3b82f6' # Default blue
  end

  def brand_secondary_color
    secondary_color.presence || '#8b5cf6' # Default purple
  end

  def logo_url
    logo.attached? ? Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true) : nil
  end

  def initials
    name.split(' ').map(&:first).join.upcase[0..1]
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def set_default_plan
    update(subscription_plan: 'free', subscription_status: 'active') if subscription_plan.nil?
  end

  def add_owner_as_member
    organization_members.create!(user: owner, role: 'owner')
  end

  def cancel_stripe_subscription
    cancel_subscription! if stripe_subscription_id.present?
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to cancel Stripe subscription: #{e.message}"
    # Don't prevent organization deletion if Stripe fails
    true
  end
end
