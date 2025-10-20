FactoryBot.define do
  factory :target do
    name { Faker::Marketing.buzzwords }
    activate_time { Time.now - 1.hour }
    expire_time { Time.now + 30.days }
    created_at { Time.now }
    updated_at { Time.now }

    # Target belongs_to :list with foreign_key :domains_list_id
    after(:build) do |target|
      target.domains_list_id = create(:list).id unless target.domains_list_id
    end

    trait :expired do
      expire_time { Time.now - 1.day }
    end

    trait :not_active do
      activate_time { Time.now + 1.day }
    end

    trait :with_campaigns do
      after(:create) do |target|
        create_list(:campaign, 2, target: target)
      end
    end
  end
end
