FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "Test User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    credits_balance { 0.0 }
  end
end
