module Discounts
  module Calculators
    class PercentageOff < Base
      def calculate
        basket_items.each do |basket_item|
          if discount.product_group.nil? || discount.product_group.products.include?(basket_item.product)
            apply_discount(basket_item)
          end
        end
      end

      def apply_discount(basket_item)
        discount_line = DiscountLine.new
        discount_line.name = "#{discount.name} - #{basket_item.product.name}"
        discount_line.price_adjustment = -(discount.reward_amount / 100.0) * basket_item.line_total(false)
        discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * basket_item.tax_amount
        discount_lines << discount_line
      end
    end
  end
end
