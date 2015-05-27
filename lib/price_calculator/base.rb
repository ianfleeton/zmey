module PriceCalculator
  # Provides a default implementation of a price calculator that simply returns
  # the product's price. Subclass this to provide more complex calculations.
  class Base
    attr_reader :basket_item
    attr_reader :product
    attr_reader :quantity

    delegate :tax_type, to: :product
    delegate :ex_tax,   to: :taxer
    delegate :inc_tax,  to: :taxer
    delegate :with_tax, to: :taxer

    def initialize(product:, quantity: 1, basket_item: nil)
      @product, @basket_item, @quantity = product, basket_item, quantity
    end

    # Returns the price of a single product. That is, it is not multiplied
    # by the quantity.
    def price
      product.price
    end

    def taxer
      @taxer ||= Taxer.new(price, tax_type)
    end
  end
end
