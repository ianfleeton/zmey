# frozen_string_literal: true

module Discounts
  module Calculators
    class AmountOffOrder < Base
      def calculate
        effective_total = EffectiveTotal.new(discount, basket)

        if effective_total.ex_vat >= discount.threshold &&
            effective_total.ex_vat.positive?
          apply_discount(effective_total)
        end
      end

      def apply_discount(effective_total)
        discount_line = DiscountLine.new(
          discount,
          name: discount.name,
          price_adjustment: - discount.reward_amount / effective_total.vat_rate
        )
        discount_line.tax_adjustment =
          - discount.reward_amount - discount_line.price_adjustment
        add_discount_line(discount_line)
      end
    end
  end
end
