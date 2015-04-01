module Discounts
  module Calculators
    # A discount calculator that makes matching products free within a basket by
    # applying a matching negative discount once per product.
    class FreeProducts < Base
      def calculate
        products = discount.product_group.products
        products.each do |product|
          break if make_product_free(product)
        end
      end

      def make_product_free(product)
        if basket_item = basket_item.find { |i| product.id == i.id }
          discount_line = DiscountLine.new
          discount_line.name = 'Free ' + product.name
          discount_line.price_adjustment = -product.price_ex_tax
          discount_line.tax_adjustment = -product.tax_amount
          discount_lines << discount_line
        end
      end
    end
  end
end
