class Admin::CreditsController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:new, :create]

  def index
    @users = User.order(created_at: :desc).limit(100)
  end

  def new
    @transaction_types = CreditTransaction::TRANSACTION_TYPES
  end

  def create
    amount = params[:amount].to_f
    transaction_type = params[:transaction_type]
    description = params[:description]

    if amount == 0
      flash[:error] = "Amount cannot be zero"
      redirect_to new_admin_user_credit_path(@user)
      return
    end

    begin
      if transaction_type == CreditTransaction::ADMIN_ADJUSTMENT
        @user.add_credits(amount, description, transaction_type)
      elsif amount > 0
        @user.add_credits(amount, description, transaction_type)
      else
        @user.deduct_credits(amount.abs, description)
      end

      flash[:success] = "Successfully #{amount > 0 ? 'added' : 'deducted'} $#{amount.abs} #{amount > 0 ? 'to' : 'from'} #{@user.email}'s account"
      redirect_to admin_credits_path
    rescue => e
      flash[:error] = "Transaction failed: #{e.message}"
      redirect_to new_admin_user_credit_path(@user)
    end
  end

  def transactions
    @user = User.find(params[:user_id])
    @transactions = @user.credit_transactions.recent.limit(100)
  end

  private

  def require_admin
    unless current_user&.admin?
      flash[:error] = 'Access denied'
      redirect_to root_path
    end
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
