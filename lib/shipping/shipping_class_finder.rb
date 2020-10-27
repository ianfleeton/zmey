# frozen_string_literal: true

module Shipping
  class ShippingClassFinder
    include BestShippingClass

    def initialize(shipping_class_id:, default_shipping_class:, delivery_address:, basket:)
      @shipping_class_id = shipping_class_id
      @default_shipping_class = default_shipping_class
      @delivery_address = delivery_address
      @basket = basket
    end

    # Returns the customer's chosen shipping class, if present
    # and valid, otherwise the default (if available) or cheapest valid shipping
    # class.
    def find
      @shipping_class = ShippingClass.find_by(id: @shipping_class_id)

      valid = ShippingClassShoppingMatch.new(@shipping_class, @basket).valid?

      unless valid
        @shipping_class = @delivery_address.try(:default_shipping_class)
        unless @shipping_class || @delivery_address
          @shipping_class = @default_shipping_class
        end
        @shipping_class ||= best_shipping_class(candidate_shipping_classes, @basket)
      end

      @shipping_class
    end

    private

    def candidate_shipping_classes
      @delivery_address.try(:shipping_classes) || []
    end
  end
end
