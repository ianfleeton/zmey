# frozen_string_literal: true

module Shipping
  class ProductsDispatchDateChecker
    attr_reader :products

    def initialize(products)
      @products = products
    end

    def locations
      products.map { |product| product.locations }.flatten.uniq
    end

    def possible?(date)
      locations.none? do |location|
        LocationOrdersExceededEntry.exists?(
          exceeded_on: date, location_id: location.id
        )
      end
    end
  end
end
