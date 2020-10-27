# frozen_string_literal: true

module Discounts
  # Finds the total value of products which can be used to determine available
  # discounts.
  class EffectiveTotal
    def initialize(discount, basket)
      @discount = discount
      @basket = basket
    end

    def to_s
      inspect
    end

    def inspect
      "#<EffectiveTotal ex_vat: #{ex_vat}, inc_vat: #{inc_vat}, vat_amount: #{vat_amount}, vat_rate: #{vat_rate}>"
    end

    def ex_vat
      @ex_vat ||= if @discount.exclude_reduced_products?
        total_of_items_at_full_price(inc_vat: false)
      else
        @basket.total(false)
      end - reward_items_total(inc_vat: false)
    end

    def inc_vat
      @inc_vat ||= if @discount.exclude_reduced_products?
        total_of_items_at_full_price(inc_vat: true)
      else
        @basket.total(true)
      end - reward_items_total(inc_vat: true)
    end

    def vat_amount
      inc_vat - ex_vat
    end

    def vat_rate
      ex_vat.positive? ? inc_vat / ex_vat : 0
    end

    private

    def total_of_items_at_full_price(inc_vat:)
      @basket.items_at_full_price.inject(0) do |sum, i|
        sum + i.line_total(inc_vat)
      end
    end

    def reward_items_total(inc_vat:)
      @basket.reward_items_total(inc_vat: inc_vat)
    end
  end
end
