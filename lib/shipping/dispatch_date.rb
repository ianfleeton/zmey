# frozen_string_literal: true

module Shipping
  class DispatchDate < ShippingDate
    # Returns truthy if this date can be used for dispatch.
    def possible?
      possible_with_closures? do |closure_date|
        closure_date.closed_on != date
      end && super
    end
  end
end
