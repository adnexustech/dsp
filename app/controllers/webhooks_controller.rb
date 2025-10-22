class WebhooksController < ApplicationController
  # Skip CSRF verification for Stripe webhooks
  skip_before_action :verify_authenticity_token
  before_action :verify_stripe_signature

  def stripe
    case @event.type
    when 'checkout.session.completed'
      handle_checkout_completed
    when 'customer.subscription.created'
      handle_subscription_created
    when 'customer.subscription.updated'
      handle_subscription_updated
    when 'customer.subscription.deleted'
      handle_subscription_deleted
    when 'invoice.payment_succeeded'
      handle_payment_succeeded
    when 'invoice.payment_failed'
      handle_payment_failed
    else
      Rails.logger.info "Unhandled Stripe webhook event: #{@event.type}"
    end

    render json: { status: 'success' }, status: :ok
  rescue => e
    Rails.logger.error "Stripe webhook error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def handle_checkout_completed
    session = @event.data.object
    
    # Check if this is a credit purchase
    if session.metadata&.[]('type') == 'credit_purchase'
      user_id = session.metadata['user_id']
      amount = session.metadata['amount'].to_f
      
      user = User.find_by(id: user_id)
      return unless user
      
      # Add credits to user account
      user.add_credits(
        amount,
        "Credit purchase via Stripe Checkout - $#{amount}",
        CreditTransaction::DEPOSIT
      )
      
      Rails.logger.info "Added $#{amount} credits to user #{user.id} from Checkout Session #{session.id}"
    end
  end

  def verify_stripe_signature
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      @event = Stripe::Webhook.construct_event(
        payload, sig_header, webhook_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: :bad_request and return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Stripe webhook signature verification failed: #{e.message}"
      render json: { error: 'Invalid signature' }, status: :bad_request and return
    end
  end

  def handle_subscription_created
    subscription = @event.data.object
    user = find_user_by_customer_id(subscription.customer)
    return unless user

    user.update!(
      stripe_subscription_id: subscription.id,
      subscription_status: subscription.status,
      trial_ends_at: subscription.trial_end ? Time.at(subscription.trial_end) : nil
    )

    Rails.logger.info "Subscription created for user #{user.id}"
  end

  def handle_subscription_updated
    subscription = @event.data.object
    user = find_user_by_customer_id(subscription.customer)
    return unless user

    # Get the plan name from subscription metadata or items
    plan_name = subscription.items.data.first&.price&.lookup_key || user.subscription_plan

    user.update!(
      subscription_status: subscription.status,
      subscription_plan: plan_name,
      trial_ends_at: subscription.trial_end ? Time.at(subscription.trial_end) : nil
    )

    Rails.logger.info "Subscription updated for user #{user.id}: #{subscription.status}"

    # Send email notifications for status changes
    case subscription.status
    when 'past_due'
      # UserMailer.payment_failed(user).deliver_later
      Rails.logger.warn "Payment past due for user #{user.id}"
    when 'canceled', 'unpaid'
      # UserMailer.subscription_canceled(user).deliver_later
      Rails.logger.info "Subscription canceled for user #{user.id}"
    end
  end

  def handle_subscription_deleted
    subscription = @event.data.object
    user = find_user_by_customer_id(subscription.customer)
    return unless user

    user.update!(
      stripe_subscription_id: nil,
      subscription_status: 'canceled',
      subscription_plan: 'free'
    )

    Rails.logger.info "Subscription deleted for user #{user.id}"
  end

  def handle_payment_succeeded
    invoice = @event.data.object
    user = find_user_by_customer_id(invoice.customer)
    return unless user

    Rails.logger.info "Payment succeeded for user #{user.id}: #{invoice.amount_paid / 100.0}"

    # Update subscription status to active if it was in trial or past_due
    if %w[trialing past_due].include?(user.subscription_status)
      user.update!(subscription_status: 'active')
    end

    # UserMailer.payment_received(user, invoice).deliver_later
  end

  def handle_payment_failed
    invoice = @event.data.object
    user = find_user_by_customer_id(invoice.customer)
    return unless user

    Rails.logger.warn "Payment failed for user #{user.id}"

    user.update!(subscription_status: 'past_due')

    # UserMailer.payment_failed(user).deliver_later
  end

  def find_user_by_customer_id(customer_id)
    User.find_by(stripe_customer_id: customer_id).tap do |user|
      Rails.logger.warn "User not found for Stripe customer: #{customer_id}" unless user
    end
  end
end
