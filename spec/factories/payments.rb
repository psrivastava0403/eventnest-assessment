FactoryBot.define do
  factory :payment do
    association :order
    amount { 59.98 }
    status { "pending" }
    provider { "stripe" }
  end
end
