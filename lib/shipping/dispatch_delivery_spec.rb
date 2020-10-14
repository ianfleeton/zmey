# frozen_string_literal: true

module Shipping
  # Specifies the constraints for determining a valid set of dispatch and
  # delivery dates.
  class DispatchDeliverySpec
    # Time from which to consider the order as ready to prepare.
    attr_accessor :start_time

    # Number of days lead time to prepare order.
    attr_accessor :lead_time

    # Number of days to deliver order.
    attr_accessor :delivery_time

    # Hour of the day after which lead time increases by one day.
    attr_accessor :cutoff_hour

    # How many dates are wanted.
    attr_accessor :num_dates

    # Object that checks dispatch dates by implementing #possible? for provided
    # dates.
    attr_accessor :dispatch_date_checker

    # items is a collection of objects that respond to #delivery_cutoff_hour.
    def initialize(start:, lead:, delivery:, cutoff:, num:, items:, dispatch_date_checker: nil)
      @start_time = start
      @lead_time = lead
      @delivery_time = delivery
      @cutoff_hour = earliest_cutoff(cutoff, items)
      @num_dates = num
      @dispatch_date_checker = dispatch_date_checker ||
        ProductsDispatchDateChecker.new(self.class.products(items))
    end

    def self.products(items)
      items.map(&:product).compact.uniq
    end

    def self.default(items:, lead_time:, shipping_class:, cutoff:)
      if shipping_class.try(:collection?)
        collection(items)
      else
        DispatchDeliverySpec.new(
          start: Time.current,
          lead: lead_time,
          delivery: 1,
          cutoff: cutoff,
          num: 20,
          items: items
        )
      end
    end

    def start_date
      start_time.to_date
    end

    def self.collection(items)
      DispatchDeliverySpec.new(
        start: Time.current,
        lead: 0,
        delivery: 0,
        cutoff: 24,
        num: 20,
        items: items
      )
    end

    private

    def earliest_cutoff(cutoff, items)
      [cutoff, items.map(&:delivery_cutoff_hour)].flatten.compact.min
    end
  end
end
