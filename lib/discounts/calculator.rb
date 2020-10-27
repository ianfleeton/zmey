# frozen_string_literal: true

module Discounts
  # Calculates discounts for a basket.
  # It delegates to a specialized calculator for each discount type.
  class Calculator
    attr_reader :basket
    attr_accessor :discounts
    attr_accessor :discount_lines

    def initialize(discounts, basket)
      @basket = basket
      @discounts = discounts
      @discount_lines = []
    end

    # Calculates discount lines.
    def calculate
      discounts.each do |discount|
        calculator_for(discount).calculate
      end
      filter_mutually_exclusive_discounts
    end

    def apply_changes_to_basket
      @basket.delete_rewards
      discount_lines.map { |dl| dl.calculator }.compact.uniq.each { |calc| calc.apply_changes_to_basket }
    end

    # Returns a calculator instance for the discount.
    def calculator_for(discount)
      calculator_class(discount).new(self, discount)
    end

    # Removes discount lines that are mutually exclusive with each other,
    # retaining the ones that are most favorable to the customer.
    def filter_mutually_exclusive_discounts
      superset = Set.new
      discount_lines.each { |dl| superset |= dl.mutually_exclusive_with }
      superset.each do |x|
        mx = discount_lines.select { |dl| dl.mutually_exclusive_with.member?(x) }
          .sort_by(&:price_adjustment)
        # Keep the best.
        mx.shift
        # Delete the rest.
        mx.each { |dl| discount_lines.delete(dl) }
      end
    end

    def add_discount_line(discount_line)
      discount_lines << discount_line
    end

    private

    def calculator_class(discount)
      Kernel.const_get(
        "Discounts::Calculators::" + discount.reward_type.camelize
      )
    end
  end
end
