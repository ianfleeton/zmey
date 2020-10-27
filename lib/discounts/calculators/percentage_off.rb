# frozen_string_literal: true

module Discounts
  module Calculators
    # Applies a percentage off discount for matching basket items.
    class PercentageOff < Base
      def calculate
        valid_items = basket_items.select { |basket_item|
          discount.product_group.nil? ||
            discount.product_group.products.include?(basket_item.product)
        }
        apply_discount(valid_items) if valid_items.any?
      end

      def apply_discount(items)
        discount_line = DiscountLine.new(
          discount,
          name: discount_name(items),
          mutually_exclusive_with: [:percentage_off_order].to_set,
          price_adjustment: price_adjustment(items),
          tax_adjustment: tax_adjustment(items)
        )
        add_discount_line(discount_line)
      end

      private

      def discount_name(items)
        "#{discount.name} - #{items.map(&:name).join(", ")}"
      end

      def price_adjustment(items)
        -(discount.reward_amount / 100.0) * items.sum { |i| i.line_total(false) }
      end

      def tax_adjustment(items)
        -(discount.reward_amount / 100.0) * items.sum(&:tax_amount)
      end
    end
  end
end
