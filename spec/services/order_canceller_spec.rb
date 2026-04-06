require 'rails_helper'

RSpec.describe OrderCanceller do
  let(:order) { create(:order, status: "confirmed") }

  it "updates status to cancelled" do
    described_class.new(order).call
    expect(order.reload.status).to eq("cancelled")
  end
end