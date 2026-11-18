module Orders
  class SalesConversion
    attr_reader :order

    def initialize(order)
      @order = order
    end

    # Returns <tt>true</tt> if a sales conversion should be recorded for the
    # order.
    def should_record?
      !order.sales_conversion_recorded_at && (order.payment_received? || order.credit_account?)
    end

    # Sets <tt>sales_conversion_recorded_at</tt> to now if it isn't already
    # set. Returns true only for the caller that recorded it, so conversion
    # tracking code is output once even if the receipt is loaded twice at the
    # same time.
    def record!
      now = Time.current
      recorded = Order
        .where(id: order.id, sales_conversion_recorded_at: nil)
        .update_all(sales_conversion_recorded_at: now, updated_at: now) == 1
      order.sales_conversion_recorded_at = now if recorded
      recorded
    end
  end
end
