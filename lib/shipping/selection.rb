# frozen_string_literal: true

module Shipping
  # Handles the updating of session when a shipping selection is made.
  class Selection
    attr_reader :option, :postcode, :session, :address, :shipping_class, :basket

    include Shipping::BestShippingClass

    def initialize(option:, postcode:, session:, address:, basket:)
      @option = option
      @postcode = postcode
      @session = session
      @address = address
      @postcode_changed = false
      @basket = basket
    end

    def update
      basket.reload if basket.persisted?

      session[:delivery_option] = option
      session[:delivery_postcode] = postcode

      if option == "collection"
        @shipping_class = ShippingClass.collection
      else
        shipping_classes = ShippingClassByPostcode.new(postcode: postcode).find_all

        @shipping_class = best_shipping_class(shipping_classes, basket)

        if address && address.postcode != postcode
          @postcode_changed = true
        end
      end

      session[:shipping_class_id] = shipping_class.id if shipping_class
    end

    def postcode_changed?
      @postcode_changed
    end
  end
end
