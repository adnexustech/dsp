class InvoicesController < ApplicationController
  before_action :authorize

  def index
    @stripe_invoices = fetch_stripe_invoices
    @credit_transactions = current_user.credit_transactions
                                      .where(transaction_type: [
                                        CreditTransaction::DEPOSIT,
                                        CreditTransaction::REFUND
                                      ])
                                      .recent
  end

  private

  def fetch_stripe_invoices
    return [] unless current_user.stripe_customer_id

    Stripe::Invoice.list(
      customer: current_user.stripe_customer_id,
      limit: 50
    ).data
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to fetch Stripe invoices: #{e.message}"
    []
  end
end
