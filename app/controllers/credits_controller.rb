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
      # Create Stripe Payment Intent for credits purchase
      payment_intent = Stripe::PaymentIntent.create(
        amount: (amount * 100).to_i, # Convert to cents
        currency: 'usd',
        customer: current_user.stripe_customer_id || create_stripe_customer_for_credits,
        metadata: {
          user_id: current_user.id,
          type: 'credit_purchase'
        },
        description: "Purchase $#{amount} in advertising credits"
      )

      # For now, we'll simulate successful payment and add credits immediately
      # In production, you'd wait for webhook confirmation
      current_user.add_credits(
        amount,
        "Credit purchase via Stripe - $#{amount}",
        CreditTransaction::DEPOSIT
      )

      flash[:success] = "Successfully added $#{amount} to your account!"
      redirect_to credits_path
    rescue Stripe::StripeError => e
      flash[:error] = "Payment failed: #{e.message}"
      redirect_to new_credit_path
    rescue => e
      flash[:error] = "An error occurred: #{e.message}"
      redirect_to new_credit_path
    end
  end

  private

  def require_login
    unless current_user
      flash[:error] = 'Please log in to manage credits'
      redirect_to login_path
    end
  end

  def create_stripe_customer_for_credits
    customer = Stripe::Customer.create(
      email: current_user.email,
      name: current_user.name,
      metadata: { user_id: current_user.id }
    )
    current_user.update!(stripe_customer_id: customer.id)
    customer.id
  end
end
