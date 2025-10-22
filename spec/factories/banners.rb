FactoryBot.define do
  factory :banner do
    sequence(:name) { |n| "Banner #{n}" }
    interval_start { Time.now - 1.hour }
    interval_end { Time.now + 30.days }
    iurl { Faker::Internet.url }
    contenttype { "text/html" }
    bid_ecpm { 2.50 }
    total_basket_value { 5000.00 }
    daily_budget { 200.00 }
    hourly_budget { 25.00 }
    total_cost { 0.00 }
    daily_cost { 0.00 }
    hourly_cost { 0.00 }
    campaign { nil }  # Optional association
    target { nil }    # Optional association

    trait :with_campaign do
      association :campaign
    end

    trait :with_target do
      association :target
    end

    trait :with_width_range do
      width_range { "300-728" }
    end

    trait :with_height_range do
      height_range { "250-600" }
    end

    trait :with_dimensions do
      width_height_list { "300x250,728x90" }
    end

    trait :expired do
      interval_end { Time.now - 1.day }
    end

    trait :not_active do
      interval_start { Time.now + 1.day }
    end

    trait :over_budget do
      total_basket_value { 100.00 }
      total_cost { 150.00 }
    end
  end
end
