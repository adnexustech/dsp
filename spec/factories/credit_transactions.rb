FactoryBot.define do
  factory :credit_transaction do
    user { nil }
    amount { "9.99" }
    transaction_type { "MyString" }
    description { "MyText" }
  end
end
