module PriceCalculator
  # Provides a default implementation of a price calculator that simply returns
  # the product's price. Subclass this to provide more complex calculations.
  class Base
    attr_reader :basket_item
    attr_reader :product
    attr_reader :quantity

    delegate :tax_type, to: :product
    delegate :ex_vat, to: :taxer
    delegate :inc_vat, to: :taxer
    delegate :with_tax, to: :taxer

    def initialize(product:, quantity: 1, basket_item: nil)
      @product, @basket_item, @quantity = product, basket_item, quantity
    end

    # Returns the price of a single product. That is, it is not multiplied
    # by the quantity.
    def price
      product.price
    end

    # Returns the weight of a single product. That is, it is not multiplied
    # by the quantity.
    def weight
      product.weight
    end

    def taxer
      @taxer ||= Taxer.new(price, tax_type)
    end

    # Returns the sum of RRP and volume purchasing savings. Other discounts are
    # not considered.
    #
    # Amount will include tax if <tt>inc_vat</tt> is true, otherwise it will
    # exclude tax.
    #
    # ==== Examples
    # * A product bought at 2.0 with no RRP set will have savings of 0.0.
    # * A single product bought at 2.0 with an RRP of 3.0 will have savings of
    #   1.0.
    # * Two products bought at 2.0 with an RRP of 3.0 will have savings of 2.0.
    # * Ten products bought with RRP unset, price of 2.0 and volume purchase
    #   price of 1.5 will have savings of 5.0.
    def savings(inc_vat:)
      return 0 unless basket_item && product

      rrp = if inc_vat
        product.rrp_inc_vat || product.price_inc_vat(1)
      else
        product.rrp_ex_vat || product.price_ex_vat(1)
      end
      (rrp * quantity) - basket_item.line_total(inc_vat)
    end
  end
end
