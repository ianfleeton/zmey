module Shipping
  extend ActiveSupport::Concern

  attr_reader :shipping_class

  protected

    # Returns the customer's delivery address or <tt>nil</tt> if the customer
    # has not yet entered one.
    def delivery_address
      @delivery_address ||= Address.find_by(id: session[:delivery_address_id])
    end

    # Sets @shipping_class to the customer's chosen shipping class, if present
    # and valid, otherwise the cheapest valid shipping class.
    def set_shipping_class
      @shipping_class = ShippingClass.find_by(id: session[:shipping_class_id])

      @shipping_class = select_cheapest_shipping_class unless @shipping_class.try(:valid_for_basket?, basket)
    end

    # Returns the cheapest valid shipping class for the customer's delivery
    # address, or <tt>nil</tt> if there aren't any.
    def select_cheapest_shipping_class
      @shipping_class = candidate_shipping_classes
        .select { |sc| sc.valid_for_basket?(basket) }
        .sort { |a, b| a.amount_for_basket(basket) <=> b.amount_for_basket(basket) }
        .first
    end

    def candidate_shipping_classes
      delivery_address.try(:shipping_classes) || []
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
