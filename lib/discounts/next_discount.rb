# frozen_string_literal: true

module Discounts
  class NextDiscount
    attr_reader :basket

    def initialize(basket:)
      @basket = basket
    end

    def close?
      delta <= Basket::NEXT_DISCOUNT_TRIGGER_VALUE if delta
    end

    def delta
      return unless threshold
      threshold - total_ex_vat(find)
    end

    def find
      potential_ordered_discounts.first
    end

    def potential_ordered_discounts
      [].tap do |potentials|
        ordered_discounts.each do |discount|
          potentials << discount if threshold_not_met? discount
        end
      end
    end

    def ordered_discounts
      discounts.sort_by(&:threshold)
    end

    private

    def threshold
      find&.threshold
    end

    def threshold_not_met?(discount)
      total_ex_vat(discount) < discount.threshold
    end

    def discounts
      Discount.current_percentage_off_order_discounts
    end

    def total_ex_vat(discount)
      EffectiveTotal.new(discount, basket).ex_vat
    end
  end
end
