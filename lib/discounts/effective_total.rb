module Discounts
  class EffectiveTotal
    def initialize(discount, basket)
      @discount, @basket = discount, basket
    end

    def ex_tax
      @ex_tax ||= if @discount.exclude_reduced_products?
        @basket.items_at_full_price.inject(0) { |sum, i| sum + i.line_total(false) }
      else
        @basket.total(false)
      end
    end

    def inc_tax
      @inx_tax ||= if @discount.exclude_reduced_products?
        @basket.items_at_full_price.inject(0) { |sum, i| sum + i.line_total(true) }
      else
        @basket.total(true)
      end
    end

    def tax_amount
      inc_tax - ex_tax
    end

    def tax_rate
      ex_tax > 0 ? inc_tax / ex_tax : 0
    end
  end
end
