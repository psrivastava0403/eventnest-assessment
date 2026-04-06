require 'rails_helper'

RSpec.describe OrderRefunder do
  let(:order) { create(:order, status: "confirmed") }

  it "updates status to refunded" do
    described_class.new(order).call
    expect(order.reload.status).to eq("refunded")
  end
end
