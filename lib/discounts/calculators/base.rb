# frozen_string_literal: true

module Discounts
  module Calculators
    class Base
      attr_reader :context
      attr_reader :discount

      delegate :add_discount_line, to: :context

      def initialize(context, discount)
        @context = context
        @discount = discount
      end

      # Helper method to easily access basket.
      def basket
        @context.basket
      end

      # Helper method to easily access basket items.
      def basket_items
        @context.basket.basket_items
      end

      # Helper method to easily access discount lines.
      def discount_lines
        @context.discount_lines
      end
    end
  end
end
