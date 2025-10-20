FactoryBot.define do
  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }
    activate_time { Time.now - 1.hour }
    expire_time { Time.now + 30.days }
    ad_domain { Faker::Internet.domain_name }
    regions { "US,CA,GB" }
    total_budget { 10000.00 }
    budget_limit_daily { 500.00 }
    budget_limit_hourly { 50.00 }
    cost { 0.00 }
    daily_cost { 0.00 }
    hourly_cost { 0.00 }
    status { "runnable" }
    exchanges { "google,rubicon,appnexus" }
    association :target

    trait :expired do
      expire_time { Time.now - 1.day }
    end

    trait :not_active do
      activate_time { Time.now + 1.day }
    end

    trait :over_budget do
      total_budget { 100.00 }
      cost { 150.00 }
    end

    trait :over_daily_budget do
      budget_limit_daily { 50.00 }
      daily_cost { 75.00 }
    end

    trait :over_hourly_budget do
      budget_limit_hourly { 10.00 }
      hourly_cost { 15.00 }
    end

    trait :with_banners do
      after(:create) do |campaign|
        create_list(:banner, 2, campaign: campaign, target: campaign.target)
      end
    end
  end
end
