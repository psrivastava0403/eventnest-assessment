require 'rails_helper'

RSpec.describe CrmSyncJob, type: :job do
  let(:order) { create(:order) }

  it "calls sync_to_crm on the order" do
    expect_any_instance_of(Order).to receive(:sync_to_crm)
    described_class.perform_now(order.id)
  end
end
