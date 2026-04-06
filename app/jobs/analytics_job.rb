class AnalyticsJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    Rails.logger.info("Tracking order #{order_id} for analytics")
  end
end
