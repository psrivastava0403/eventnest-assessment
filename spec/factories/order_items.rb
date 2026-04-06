FactoryBot.define do
  factory :order_item do
    association :order
    association :ticket_tier
    quantity { 2 }
    unit_price { 29.99 }
  end
end
