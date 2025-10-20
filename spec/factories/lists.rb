FactoryBot.define do
  factory :list do
    name { Faker::Marketing.buzzwords }
    description { Faker::Lorem.sentence }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
