class OrderCreator
  def initialize(user:, event:, items:)
    @user = user
    @event = event
    @items = items
  end

  def call
    Order.transaction do
      order = Order.new(user: @user, event: @event, status: "pending")
      order.confirmation_number = generate_confirmation_number

      # Attach items to the order
      @items.each do |item|
        order.order_items << item
      end

      # Calculate total based on attached items
      order.total_amount = calculate_total(order.order_items)
      order.save!

      reserve_tickets(order)
      Payment.create!(order: order, amount: order.total_amount, status: "pending")

      # enqueue background jobs
      OrderMailerJob.perform_later(order.id, :confirmation)
      AnalyticsJob.perform_later(order.id)
      CrmSyncJob.perform_later(order.id)

      order
    end
  end


  private

  def generate_confirmation_number
    "EVN-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_total(items)
    items.sum { |item| item.quantity * item.unit_price }
  end

  def reserve_tickets(order)
    order.order_items.each do |item|
      item.ticket_tier.reserve_tickets!(item.quantity)
    end
  end
end
