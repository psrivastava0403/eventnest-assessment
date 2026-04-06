require 'rails_helper'

RSpec.describe OrderConfirmer do
  let(:order) { create(:order, status: "pending") }

  it "updates status to confirmed" do
    described_class.new(order).call
    expect(order.reload.status).to eq("confirmed")
  end
end
