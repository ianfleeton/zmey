# frozen_string_literal: true

module Discounts
  module Calculators
    # A discount calculator that adds a single percentage discount off the
    # order if the effective order value meets the minimum threshold.
    class PercentageOffOrder < Base
      def calculate
        effective_total = EffectiveTotal.new(discount, basket)

        apply_discount(effective_total) if threshold_met?(effective_total)
      end

      def apply_discount(effective_total)
        discount_line = DiscountLine.new(
          discount,
          name: discount.name,
          mutually_exclusive_with: [:percentage_off_order].to_set,
          price_adjustment: -(discount.reward_amount / 100.0) * effective_total.ex_vat,
          tax_adjustment: -(discount.reward_amount / 100.0) * effective_total.vat_amount
        )
        add_discount_line(discount_line)
      end

      private

      def threshold_met?(total)
        total.ex_vat >= discount.threshold && total.ex_vat.positive?
      end
    end
  end
end
