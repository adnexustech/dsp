# frozen_string_literal: true

FactoryBot.define do
  factory :rtb_standard do
    sequence(:name) { |n| "RTB Standard #{n}" }
    rtbspecification { "OpenRTB 2.5" }
    operator { "eq" }
    operand { "device.geo.country" }
    operand_type { "string" }
    operand_ordinal { "1" }
    rtb_required { false }
    description { "RTB Standard rule" }
    association :list, factory: :list
  end
end
