module Discounts
  module Calculators
    class AmountOffOrder < Base
      def calculate
        effective_total = EffectiveTotal.new(discount, basket)

        if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
          apply_discount(effective_total)
        end
      end

      def apply_discount(effective_total)
        discount_line = DiscountLine.new
        discount_line.name = discount.name
        discount_line.price_adjustment = -discount.reward_amount / effective_total.tax_rate
        discount_line.tax_adjustment = - discount.reward_amount - discount_line.price_adjustment
        discount_lines << discount_line
      end
    end
  end
end
