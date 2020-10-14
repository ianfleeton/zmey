# frozen_string_literal: true

module Orders
  class Recycler
    # Returns a new order or recycles a previous order specified by +id+ if that
    # order is eligible for recycling, that is, it exists and is in the waiting
    # for payment state.
    def self.new_or_recycled(id)
      order = Order.find_by(id: id)
      if order&.waiting_for_payment? && order.paid_on.nil?
        order.order_lines.delete_all
        order
      else
        Order.new
      end
    end
  end
end
