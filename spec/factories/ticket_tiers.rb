FactoryBot.define do
  factory :ticket_tier do
    name { "General Admission" }
    price { 29.99 }
    quantity { 100 }
    sold_count { 0 }
    association :event
  end
end
