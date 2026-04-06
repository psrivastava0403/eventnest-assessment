require 'rails_helper'

RSpec.describe OrderCreator do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:tier) { create(:ticket_tier, event: event, price: 100) }
  let(:items) { [OrderItem.new(ticket_tier: tier, quantity: 2, unit_price: tier.price)] }

  it "creates an order with confirmation number and payment" do
    order = described_class.new(user: user, event: event, items: items).call
    expect(order.confirmation_number).to be_present
    expect(order.payment).to be_present
    expect(order.total_amount).to eq(200)
  end
end
