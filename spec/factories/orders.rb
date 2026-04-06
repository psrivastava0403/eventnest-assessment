FactoryBot.define do
  factory :order do
    association :user
    association :event
    status { "pending" }
    total_amount { 100.0 }

    before(:create) do |order|
      order.class.skip_callback(:create, :before, :calculate_total, raise: false)
      order.class.skip_callback(:create, :after, :create_pending_payment, raise: false)
    end

    after(:create) do |order|
      order.class.set_callback(:create, :before, :calculate_total)
      order.class.set_callback(:create, :after, :create_pending_payment)
    end
  end
end
