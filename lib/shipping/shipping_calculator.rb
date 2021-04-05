module Shipping
  class ShippingCalculator
    def initialize(options)
      @options = options
    end

    def amount
      amount = BigDecimal("0")
      amount_for_basket = @options[:shipping_class].try(:amount_for, basket, @options[:delivery_date])
      amount_for_basket || amount
    end

    def vat_amount
      if @options[:shipping_class].nil? || @options[:shipping_class].charge_vat?
        Product.vat_rate * amount.to_f
      else
        BigDecimal("0")
      end
    end

    def quote_needed?
      overweight? || empty_shipping_table?
    end

    private

    def basket
      @options[:basket]
    end

    def overweight?
      basket.overweight?(max_product_weight: max_product_weight)
    end

    def max_product_weight
      shipping_class.try(:max_product_weight) || 0
    end

    def empty_shipping_table?
      shipping_class && shipping_class.shipping_table_rows.count == 0
    end

    def shipping_class
      @options[:shipping_class]
    end
  end
end
