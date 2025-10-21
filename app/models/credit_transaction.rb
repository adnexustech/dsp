class CreditTransaction < ApplicationRecord
  # Transaction types
  DEPOSIT = 'deposit'.freeze
  SPEND = 'spend'.freeze
  REFUND = 'refund'.freeze
  ADMIN_ADJUSTMENT = 'admin_adjustment'.freeze

  TRANSACTION_TYPES = [DEPOSIT, SPEND, REFUND, ADMIN_ADJUSTMENT].freeze

  belongs_to :user

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }
  validates :description, presence: true

  scope :deposits, -> { where(transaction_type: DEPOSIT) }
  scope :spends, -> { where(transaction_type: SPEND) }
  scope :refunds, -> { where(transaction_type: REFUND) }
  scope :admin_adjustments, -> { where(transaction_type: ADMIN_ADJUSTMENT) }
  scope :recent, -> { order(created_at: :desc) }

  # Check if transaction adds credits
  def credit?
    [DEPOSIT, REFUND, ADMIN_ADJUSTMENT].include?(transaction_type) && amount > 0
  end

  # Check if transaction deducts credits
  def debit?
    transaction_type == SPEND || (transaction_type == ADMIN_ADJUSTMENT && amount < 0)
  end

  # Display amount with sign
  def signed_amount
    credit? ? "+#{amount}" : amount.to_s
  end
end
