class SubscriptionsController < ApplicationController
  before_action :require_login

  def index
    @subscription = current_user.stripe_subscription_id ?
      Stripe::Subscription.retrieve(current_user.stripe_subscription_id) : nil
    @plan = current_user.plan_features
    @invoices = fetch_invoices
  rescue Stripe::StripeError => e
    flash[:error] = "Unable to load subscription details: #{e.message}"
    redirect_to root_path
  end

  def new
    @plans = STRIPE_PLANS
    @current_plan = current_user.subscription_plan&.to_sym || :free
  end

  def create
    plan_name = params[:plan]

    if plan_name == 'free'
      # Cancel existing subscription if any
      current_user.cancel_subscription! if current_user.stripe_subscription_id
      
      current_user.update!(
        subscription_plan: 'free',
        subscription_status: 'active',
        stripe_subscription_id: nil
      )
      flash[:success] = 'Switched to Free plan successfully!'
      redirect_to subscriptions_path
      return
    end

    begin
      plan = STRIPE_PLANS[plan_name.to_sym]
      raise ArgumentError, "Invalid plan: #{plan_name}" unless plan

      # Ensure Stripe customer exists
      unless current_user.stripe_customer_id
        customer = Stripe::Customer.create(
          email: current_user.email,
          name: current_user.name,
          metadata: { user_id: current_user.id }
        )
        current_user.update!(stripe_customer_id: customer.id)
      end

      # Create Stripe Checkout Session for subscription
      session = Stripe::Checkout::Session.create(
        customer: current_user.stripe_customer_id,
        payment_method_types: ['card'],
        line_items: [{
          price: plan[:stripe_price_id],
          quantity: 1
        }],
        mode: 'subscription',
        success_url: subscriptions_url + '?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: new_subscription_url,
        subscription_data: {
          metadata: {
            user_id: current_user.id,
            plan_name: plan_name
          }
        }
      )

      # Redirect to Stripe Checkout page
      redirect_to session.url, allow_other_host: true
    rescue ArgumentError => e
      flash[:error] = e.message
      redirect_to new_subscription_path
    rescue Stripe::StripeError => e
      flash[:error] = "Unable to start checkout: #{e.message}"
      redirect_to new_subscription_path
    end
  end

  def cancel
    begin
      current_user.cancel_subscription!
      flash[:success] = 'Subscription canceled successfully. You still have access until the end of your billing period.'
      redirect_to subscriptions_path
    rescue Stripe::StripeError => e
      flash[:error] = "Failed to cancel subscription: #{e.message}"
      redirect_to subscriptions_path
    end
  end

  def portal
    # Redirect to Stripe Customer Portal for self-service management
    begin
      session = Stripe::BillingPortal::Session.create(
        customer: current_user.stripe_customer_id,
        return_url: subscriptions_url
      )
      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      flash[:error] = "Unable to access billing portal: #{e.message}"
      redirect_to subscriptions_path
    end
  end

  private

  def require_login
    unless current_user
      flash[:error] = 'Please log in to manage your subscription'
      redirect_to login_path
    end
  end

  def create_stripe_customer
    current_user.create_stripe_customer! unless current_user.stripe_customer_id
  rescue Stripe::StripeError => e
    flash[:error] = "Unable to create customer: #{e.message}"
    redirect_to root_path
  end

  def fetch_invoices
    return [] unless current_user.stripe_customer_id

    Stripe::Invoice.list(
      customer: current_user.stripe_customer_id,
      limit: 10
    ).data
  rescue Stripe::StripeError
    []
  end
end
