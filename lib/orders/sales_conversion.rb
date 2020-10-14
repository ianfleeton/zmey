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

    # Sets <tt>sales_conversion_recorded_at</tt> to now and saves the order.
    def record!
      order.sales_conversion_recorded_at = Time.zone.now
      order.save
    end
  end
end
