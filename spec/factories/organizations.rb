FactoryBot.define do
  factory :organization do
    name { "MyString" }
    slug { "MyString" }
    stripe_customer_id { "MyString" }
    stripe_subscription_id { "MyString" }
    subscription_plan { "MyString" }
    subscription_status { "MyString" }
    credits_balance { "9.99" }
    owner_id { 1 }
  end
end
