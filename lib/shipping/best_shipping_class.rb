# frozen_string_literal: true

module Shipping
  module BestShippingClass
    # Returns the best shipping class for a basket out of the candidate shipping
    # classes provided, or <tt>nil</tt> if there aren't any. It chooses the
    # cheapest shipping class for the customer.
    def best_shipping_class(shipping_classes, basket)
      shipping_classes
        .select { |sc| Shipping::ShippingClassShoppingMatch.new(sc, basket).valid? }
        .min { |a, b| amount(a, basket) <=> amount(b, basket) }
    end

    def amount(shipping_class, basket)
      shipping_class.amount_for(basket)
    end
  end
end
