module Api
  module V1
    class OrdersController < ApplicationController

      def index
        orders = current_user.orders
                              .recent
                              .includes(:event, :order_items)

        render json: orders.map { |order|
          {
            id: order.id,
            confirmation_number: order.confirmation_number,
            event: order.event.title,
            status: order.status,
            total_amount: order.total_amount.to_f,
            items_count: order.order_items.size,
            created_at: order.created_at
          }
        }
      end

      def show
        order = current_user.orders
                            .includes(:event, :payment, order_items: :ticket_tier)
                            .find(params[:id])

        render json: {
          id: order.id,
          confirmation_number: order.confirmation_number,
          status: order.status,
          total_amount: order.total_amount.to_f,
          event: {
            id: order.event.id,
            title: order.event.title,
            starts_at: order.event.starts_at
          },
          items: order.order_items.map { |item|
            {
              ticket_tier: item.ticket_tier.name,
              quantity: item.quantity,
              unit_price: item.unit_price.to_f,
              subtotal: item.subtotal.to_f
            }
          },
          payment: order.payment ? {
            status: order.payment.status,
            provider_reference: order.payment.provider_reference
          } : nil
        }
      end

      def create
        event = Event.find(params[:event_id])

        # Build order items from params
        items = params.require(:items).map do |item_data|
          tier = TicketTier.find(item_data[:ticket_tier_id])
          OrderItem.new(
            ticket_tier: tier,
            quantity: item_data[:quantity].to_i,
            unit_price: tier.price
          )
        end

        # Use the service object
        order = OrderCreator.new(user: current_user, event: event, items: items).call

        render json: {
          id: order.id,
          confirmation_number: order.confirmation_number,
          status: order.status,
          total_amount: order.total_amount.to_f,
          payment_status: order.payment.status
        }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def cancel
        order = current_user.orders.find(params[:id])

        if order.status.in?(%w[pending confirmed])
          OrderCanceller.new(order).call
          render json: { message: "Order cancelled", status: order.status }
        else
          render json: { error: "Cannot cancel order in #{order.status} status" }, status: :unprocessable_entity
        end
      end

      def confirm
        order = current_user.orders.find(params[:id])
        OrderConfirmer.new(order).call
        render json: { message: "Order confirmed", status: order.status }
      end

      def refund
        order = current_user.orders.find(params[:id])
        OrderRefunder.new(order).call
        render json: { message: "Order refunded", status: order.status }
      end
    end
  end
end
