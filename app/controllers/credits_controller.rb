class CreditsController < ApplicationController
  before_action :require_login

  def index
    @balance = current_user.credits_balance
    @transactions = current_user.credit_transactions.recent.limit(50)
    @min_deposit = User::MIN_DEPOSIT_AMOUNT
  end

  def new
    @min_deposit = User::MIN_DEPOSIT_AMOUNT
  end

  def create
    amount = params[:amount].to_f

    if amount < User::MIN_DEPOSIT_AMOUNT
      flash[:error] = "Minimum deposit is $#{User::MIN_DEPOSIT_AMOUNT}"
      redirect_to new_credit_path
      return
    end

    begin
      # Ensure user has a Stripe customer
      customer_id = current_user.stripe_customer_id || create_stripe_customer

      # Create a Stripe Checkout Session for REAL payment collection
      session = Stripe::Checkout::Session.create(
        customer: customer_id,
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'Advertising Credits',
              description: "Purchase $#{amount} in advertising credits"
            },
            unit_amount: (amount * 100).to_i # Convert to cents
          },
          quantity: 1
        }],
        mode: 'payment',
        success_url: credits_success_url(amount: amount),
        cancel_url: new_credit_url,
        metadata: {
          user_id: current_user.id,
          amount: amount,
          type: 'credit_purchase'
        }
      )

      # Redirect to Stripe Checkout page
      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      flash[:error] = "Payment failed: #{e.message}"
      redirect_to new_credit_path
    rescue => e
      flash[:error] = "An error occurred: #{e.message}"
      redirect_to new_credit_path
    end
  end

  def success
    # This is called after successful payment
    # Actual credit addition happens via webhook
    amount = params[:amount].to_f
    flash[:success] = "Payment successful! Your $#{amount} in credits will be added shortly."
    redirect_to credits_path
  end

  def cancel
    flash[:warning] = "Payment cancelled. No charges were made."
    redirect_to new_credit_path
  end

  private

  def require_login
    unless current_user
      flash[:error] = 'Please log in to manage credits'
      redirect_to login_path
    end
  end

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email: current_user.email,
      name: current_user.name,
      metadata: { user_id: current_user.id }
    )
    current_user.update!(stripe_customer_id: customer.id)
    customer.id
  end
end
