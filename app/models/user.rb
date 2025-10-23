class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :credit_transactions, dependent: :destroy
  has_many :organization_members, dependent: :destroy
  has_many :organizations, through: :organization_members
  has_many :owned_organizations, class_name: 'Organization', foreign_key: 'owner_id', dependent: :destroy
  belongs_to :current_organization, class_name: 'Organization', optional: true
  has_one_attached :avatar

  # Constants
  MIN_DEPOSIT_AMOUNT = 10.00
  MIN_DAILY_BUDGET = 25.00

  # Stripe subscription statuses (kept for backward compatibility during migration)
  SUBSCRIPTION_STATUSES = %w[trialing active past_due canceled unpaid incomplete incomplete_expired].freeze
  SUBSCRIPTION_PLANS = %w[free basic pro enterprise].freeze

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :subscription_plan, inclusion: { in: SUBSCRIPTION_PLANS }, allow_nil: true
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }, allow_nil: true
  validates :credits_balance, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  after_create :set_default_plan
  after_create :create_personal_organization
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
      email: email,
      name: name,
      metadata: { user_id: id }
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

  # Organization Management
  def personal_organization
    owned_organizations.find_by(name: "#{name || email}'s Organization")
  end

  def switch_organization(organization)
    return false unless can_access_organization?(organization)
    update(current_organization: organization)
  end

  def can_access_organization?(organization)
    organizations.include?(organization)
  end

  def current_org
    current_organization || personal_organization || organizations.first
  end

  # Profile Methods
  def avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true) : nil
  end

  def initials
    if name.present?
      name.split(' ').map(&:first).join.upcase[0..1]
    else
      email[0..1].upcase
    end
  end

  def skills_array
    skills.present? ? skills.split(',').map(&:strip) : []
  end

  def service_categories_array
    service_categories.present? ? service_categories.split(',').map(&:strip) : []
  end

  def profile_complete?
    bio.present? && skills.present? && avatar.attached?
  end

  def service_provider?
    available_for_hire && profile_complete?
  end

  private

  def create_personal_organization
    org = Organization.create!(
      name: "#{name || email}'s Organization",
      owner: self,
      credits_balance: 0.0
    )
    update(current_organization: org)
  end

  def set_default_plan
    update(subscription_plan: 'free', subscription_status: 'active') if subscription_plan.nil?
  end

  def cancel_stripe_subscription
    cancel_subscription! if stripe_subscription_id.present?
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to cancel Stripe subscription: #{e.message}"
    # Don't prevent user deletion if Stripe fails
    true
  end
end
