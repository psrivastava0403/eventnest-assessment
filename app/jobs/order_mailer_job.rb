class OrderMailerJob < ApplicationJob
  queue_as :default

  def perform(order_id, type)
    order = Order.find(order_id)
    case type
    when :confirmation
      UserMailer.order_confirmation(order.user, order).deliver_later
    when :confirmed
      UserMailer.order_confirmed(order.user, order).deliver_later
    when :cancelled
      UserMailer.order_cancelled(order.user, order).deliver_later
    end
  end
end
