class OrderCanceller
  def initialize(order)
    @order = order
  end

  def call
    @order.update!(status: "cancelled")
    OrderMailerJob.perform_later(@order.id, :cancelled)
    CrmSyncJob.perform_later(@order.id)
  end
end
