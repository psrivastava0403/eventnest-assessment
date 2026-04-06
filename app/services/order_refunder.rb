class OrderRefunder
  def initialize(order)
    @order = order
  end

  def call
    @order.update!(status: "refunded")
    RefundProcessorJob.perform_later(@order.id)
    CrmSyncJob.perform_later(@order.id)
  end
end
