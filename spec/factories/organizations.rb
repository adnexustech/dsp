FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:slug) { |n| "org-#{n}" }
    stripe_customer_id { nil }
    stripe_subscription_id { nil }
    subscription_plan { 'free' }
    subscription_status { 'active' }
    credits_balance { 0.0 }

    # Association - use trait or explicitly set in tests
    transient do
      owner { nil }
    end

    after(:build) do |organization, evaluator|
      organization.owner_id = evaluator.owner&.id if evaluator.owner
    end
  end
end
