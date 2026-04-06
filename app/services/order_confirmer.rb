class OrderConfirmer
  def initialize(order)
    @order = order
  end

  def call
    @order.update!(status: "confirmed")
    OrderMailerJob.perform_later(@order.id, :confirmed)
    CrmSyncJob.perform_later(@order.id)
  end
end
