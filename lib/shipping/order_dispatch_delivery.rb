# frozen_string_literal: true

module Shipping
  # Provides methods for validating, enumerating, and updating dispatch and
  # delivery dates for the given order.
  class OrderDispatchDelivery
    attr_reader :order, :time, :cutoff

    def initialize(order, cutoff:, time: Time.current)
      @order = order
      @time = time
      @cutoff = cutoff
    end

    # Returns truthy if the dispatch and delivery dates for this order are
    # valid, or falsey if not.
    def valid?
      if needs_delivery_date?
        dispatch_delivery_dates.include?(dispatch_delivery_date)
      else
        true
      end
    end

    # Returns an array of valid delivery dates.
    def delivery_dates
      dispatch_delivery_dates.map(&:delivery_date)
    end

    def use_first_possible_delivery_date
      self.delivery_date = delivery_dates.first
    end

    # Sets the delivery date for the order. The dispatch date is also amended
    # accordingly. The order is saved if the new details are valid.
    def delivery_date=(date)
      date = Date.parse(date) if date.is_a?(String)

      order.delivery_date = date
      order.dispatch_date = DispatchDeliveryDate.dispatch_date(spec, date)
      order.save if valid?
    end

    def needs_delivery_date?
      shipping_class.try(:choose_date) && !fully_shipped?
    end

    # Returns a dispatch date worked back from the order's relevant delivery
    # date. Returns +nil+ if the order does not have a relevant delivery date..
    def dispatch_date
      date = order.relevant_delivery_date
      return nil unless date

      dd_spec = spec
      # 7 days in plenty of time to work back from delivery date to find a
      # dispatch date
      dd_spec.start_time = (date - 7.days).at_beginning_of_day
      DispatchDeliveryDate.dispatch_date(dd_spec, date)
    end

    # The specification used for finding valid dispatch and delivery dates.
    def spec
      dd_spec = DispatchDeliverySpec.default(
        items: order.order_lines, lead_time: order.lead_time,
        shipping_class: shipping_class,
        cutoff: cutoff
      )
      dd_spec.start_time = time
      dd_spec
    end

    private

    def dispatch_delivery_dates
      DispatchDeliveryDate.list(spec)
    end

    def basket
      @basket ||= order.basket
    end

    def fully_shipped?
      order.fully_shipped?
    end

    def shipping_class
      ShippingClass.find_by(name: order.shipping_method)
    end

    def dispatch_delivery_date
      DispatchDeliveryDate.new(order.dispatch_date, order.delivery_date)
    end
  end
end
