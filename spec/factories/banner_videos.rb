FactoryBot.define do
  factory :banner_video do
    sequence(:name) { |n| "Video Ad #{n}" }
    interval_start { Time.now - 1.hour }
    interval_end { Time.now + 30.days }
    mime_type { "video/mp4" }
    bid_ecpm { 5.00 }
    bitrate { 1500 }
    total_basket_value { 10000.00 }
    daily_budget { 500.00 }
    hourly_budget { 50.00 }
    total_cost { 0.00 }
    daily_cost { 0.00 }
    hourly_cost { 0.00 }
    association :campaign
    association :target

    trait :with_dimensions do
      width_range { "640-1920" }
      height_range { "480-1080" }
      width_height_list { "640x480,1280x720,1920x1080" }
    end

    trait :expired do
      interval_end { Time.now - 1.day }
    end

    trait :over_budget do
      total_basket_value { 100.00 }
      total_cost { 150.00 }
    end
  end
end
