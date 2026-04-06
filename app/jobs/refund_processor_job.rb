class RefundProcessorJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    Rails.logger.info("Processing refund for order #{order.id}")
    # later add refund logic
  end
end
