module Discounts
  # Calculates discounts for a basket based on applicable coupons. It delegates
  # to a specialized calculator for each discount type.
  class Calculator
    attr_reader :basket
    attr_reader :coupons
    attr_accessor :discounts
    attr_accessor :discount_lines

    def initialize(discounts, coupons, basket)
      @basket, @discounts = basket, discounts
      @coupons = coupons || []
      @discount_lines = []
    end

    # Returns <tt>true</tt> if the discount doesn't require a coupon code or if
    # the customer has supplied the correct coupon code.
    def authorized?(discount)
      discount.coupon.blank? || coupons.include?(discount.coupon)
    end

    # Calculates discount lines.
    def calculate
      discounts.each do |discount|
        calculator_for(discount).calculate if authorized?(discount)
      end
    end

    # Returns a calculator instance for the discount.
    def calculator_for(discount)
      calculator_class(discount).new(self, discount)
    end

    private

      def calculator_class(discount)
        Kernel.const_get('Discounts::Calculators::' + discount.reward_type.camelize)
      end
  end
end
