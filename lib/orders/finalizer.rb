# frozen_string_literal: true

module Orders
  class Finalizer
    attr_reader :website

    def initialize(website)
      @website = website
    end

    # Associates the payment with the order, saves it, and sends any
    # confirmation emails needed.
    def finalize_with_payment(payment)
      if (order = Order.matching_new_payment(payment))
        update_order(order, payment)

        # Mobile order conversions are recorded from mobile apps using Firebase
        # Analytics so we should mark them as already recorded.
        SalesConversion.new(order).record! if order.mobile_app?

        record_discount_use(order)
      end
    end

    # Sends an order confirmation email to the customer and website owner.
    def send_confirmation(order)
      OrderNotifier.confirmation(website, order).deliver_later
    end

    private

    def update_order(order, payment)
      payment.order = order
      # The saving of a payment linked to the order will trigger the order to
      # update and save any new status.
      payment.save
      send_confirmation(order) if order.payment_received? && !payment.paypal_ipn?
    end

    def record_discount_use(order)
      order.discounts.map(&:record_use)
    end
  end
end
