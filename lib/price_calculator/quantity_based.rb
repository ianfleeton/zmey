module PriceCalculator
  class QuantityBased < Base
    delegate :price_at_quantity, to: :product

    def price
      price_at_quantity(basket_item.quantity)
    end
  end
end
