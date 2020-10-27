# frozen_string_literal: true

module Shipping
  class ShippingClassShoppingMatch
    include ActiveModel::Model
    attr_accessor :shipping_class, :shopping

    validate :shipping_class_present
    validate :valid_for_size, if: -> { shipping_class }

    def initialize(shipping_class, shopping)
      @shipping_class = shipping_class
      @shopping = shopping
    end

    def shipping_class_present
      errors.add(:shipping_class, "is not present") unless shipping_class_present?
    end

    def shipping_class_present?
      @shipping_class
    end

    def valid_for_size
      errors.add(:shopping, "Shopping is too large") unless valid_for_size?
    end

    def valid_for_size?
      shipping_class_present? && (shipping_class.allow_oversize? || !shopping&.oversize?)
    end
  end
end
