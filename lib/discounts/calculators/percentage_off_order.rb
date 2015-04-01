module Discounts
  module Calculators
    # A discount calculator that adds a single percentage discount off the
    # order if the effective order value meets the minimum threshold.
    class PercentageOffOrder < Base
      def calculate
        effective_total = EffectiveTotal.new(discount, basket)

        if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
          apply_discount(effective_total)
        end
      end

      def apply_discount(effective_total)
        discount_line = DiscountLine.new(mutually_exclusive_with: [:percentage_off_order].to_set)
        discount_line.name = discount.name
        discount_line.price_adjustment = -(discount.reward_amount / 100.0) * effective_total.ex_tax
        discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * effective_total.tax_amount
        discount_lines << discount_line
      end
    end
  end
end
