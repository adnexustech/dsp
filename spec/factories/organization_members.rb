FactoryBot.define do
  factory :organization_member do
    organization { nil }
    user { nil }
    role { "MyString" }
  end
end
