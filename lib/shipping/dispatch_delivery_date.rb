# frozen_string_literal: true

module Shipping
  # Represents a dispatch date and delivery date pair. Provides class level
  # methods for finding valid dispatch/delivery dates based on provided
  # DispatchDeliverySpec.
  class DispatchDeliveryDate
    attr_reader :dispatch_date, :delivery_date

    def initialize(dispatch, delivery)
      @dispatch_date = dispatch
      @delivery_date = delivery
    end

    def to_s
      "Dispatch: #{@dispatch_date}, Delivery: #{@delivery_date}"
    end

    def ==(other)
      other.class == self.class && state == other.state
    end
    alias_method :eql?, :==

    def self.list(spec)
      @spec = spec

      dispatch = first_date

      list = []

      @spec.num_dates.times do
        delivery = DeliveryDate.new(dispatch.date)
        @spec.delivery_time.times { delivery.next_date! }
        list << DispatchDeliveryDate.new(dispatch, delivery)
        dispatch = dispatch.next_date
      end

      list
    end

    def self.delivery_dates(spec)
      list(spec).map(&:delivery_date)
    end

    # Returns the matching dispatch date for the given delivery date that meets
    # the requirements of the spec. Returns nil if no matching date is found.
    def self.dispatch_date(spec, delivery_date)
      found = list(spec).select { |dd| dd.delivery_date == delivery_date }
      found.first.dispatch_date if found.any?
    end

    def self.first_date
      date = DispatchDate.new(
        @spec.start_date - 1.day
      )
      date.next_date!

      @spec.lead_time.times { date.next_date! }

      date.next_date! if past_cut_off?

      # Now we've worked past the lead time and cut off time we can apply
      # the dispatch date checker to this and future dates.
      date.date_checker = @spec.dispatch_date_checker
      date.next_date! unless date.possible?

      date
    end

    def self.past_cut_off?
      @spec.start_time.hour >= @spec.cutoff_hour &&
        DispatchDate.new(@spec.start_date).possible?
    end

    protected

    def state
      [@dispatch_date, @delivery_date]
    end
  end
end
