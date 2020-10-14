# frozen_string_literal: true

module Shipping
  class DeliveryDate < ShippingDate
    # Returns truthy if this date can be used for delivery.
    def possible?
      possible_with_closures? do |closure_date|
        closure_date.closed_on != date || closure_date.delivery_possible?
      end
    end
  end
end
