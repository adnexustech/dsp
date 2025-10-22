# frozen_string_literal: true

# Credit validation concern for campaigns and ad serving
# Ensures users have sufficient credits before running ads
module CreditValidatable
  extend ActiveSupport::Concern

  included do
    before_save :validate_sufficient_credits, if: :active_or_activating?
    validate :check_minimum_daily_budget
  end

  # Check if campaign is being activated or is already active
  def active_or_activating?
    (status_changed? && status == 'active') || status == 'active'
  end

  # Validate user has enough credits to run campaign
  def validate_sufficient_credits
    return true unless user # Skip if no user association

    min_required = calculate_minimum_required_credits
    available = user.total_available_credits

    if available < min_required
      errors.add(:base, "Insufficient credits. You need $#{min_required} but only have $#{available}. Please add credits to your wallet.")
      throw :abort
    end
  end

  # Check if daily budget meets minimum
  def check_minimum_daily_budget
    return unless daily_budget.present?

    if daily_budget < User::MIN_DAILY_BUDGET
      errors.add(:daily_budget, "must be at least $#{User::MIN_DAILY_BUDGET}")
    end
  end

  # Calculate minimum credits needed for 1 day
  def calculate_minimum_required_credits
    return 0 unless daily_budget.present?

    # Require at least 1 day's budget available
    daily_budget
  end

  # Check if campaign can serve ads right now
  def can_serve_ads?
    return false unless status == 'active'
    return false unless user

    user.total_available_credits >= User::MIN_DAILY_BUDGET
  end

  # Check if campaign should be paused due to low credits
  def should_pause_for_credits?
    return false unless status == 'active'
    return false unless user

    user.total_available_credits < User::MIN_DAILY_BUDGET
  end
end
