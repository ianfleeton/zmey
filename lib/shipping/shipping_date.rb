# frozen_string_literal: true

module Shipping
  class ShippingDate
    attr_reader :date
    attr_accessor :date_checker

    def ==(other)
      # If a date's been provided, compare to that.
      if other.instance_of? Date
        date == other
      else
        other.class == self.class && other.date == date
      end
    end
    alias_method :eql?, :==

    def initialize(date, date_checker = nil)
      @date = date
      @date_checker = date_checker
    end

    def to_s
      date.to_s
    end

    def method_missing(meth, *args)
      if @date.respond_to?(meth)
        @date.send(meth, *args)
      else
        super
      end
    end

    def respond_to_missing?(meth, p2 = nil)
      @date.respond_to?(meth, p2) || super
    end

    # Advances this object's date to the next possible date.
    def next_date!
      Kernel.loop do
        @date += 1.day
        return if possible?
      end
    end

    # Returns the next possible date.
    def next_date
      d = date
      Kernel.loop do
        d += 1.day
        sd = self.class.new(d, date_checker)
        return sd if sd.possible?
      end
    end

    def possible?
      if @date_checker
        @date_checker.possible?(date)
      else
        true
      end
    end

    # Returns truthy if the current date is possible. Yields each closure date
    # to the given block, which should return true if the given closure date is
    # possible.
    def possible_with_closures?
      return false if date.saturday?
      return false if date.sunday?
      ClosureDate.all.all? { |cd| yield(cd) }
    end
  end
end
