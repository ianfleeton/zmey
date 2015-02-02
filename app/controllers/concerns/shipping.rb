module Shipping
  extend ActiveSupport::Concern

  attr_reader :shipping_class

  protected

    # Returns the customer's delivery address or <tt>nil</tt> if the customer
    # has not yet entered one.
    def delivery_address
      @delivery_address ||= Address.find_by(id: session[:delivery_address_id])
    end

    def set_shipping_class
      @shipping_class =
        ShippingClass.find_by(id: session[:shipping_class_id]) ||
        delivery_address.try(:first_shipping_class)
    end

    def set_shipping_amount
      @shipping_amount = shipping_amount
      @shipping_tax_amount = shipping_tax_amount
    end

    # Calculates shipping amount based on the global website shipping amount
    # and whether shipping is applicable to any products in the basket.
    def shipping_amount
      shipping_calculator.amount
    end

    def shipping_tax_amount
      shipping_calculator.tax_amount
    end

    def shipping_calculator
      @shipping_calculator ||=
        ShippingCalculator.new(
          add_tax: website.vat_number.present?,
          shipping_class: @shipping_class,
          default_amount: website.shipping_amount,
          basket: basket
        )
    end
end
