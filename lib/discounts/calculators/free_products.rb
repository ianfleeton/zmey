# frozen_string_literal: true

module Discounts
  module Calculators
    # A discount calculator that makes matching products free within a basket by
    # applying a matching negative discount once per product.
    class FreeProducts < Base
      def calculate
        effective_total = EffectiveTotal.new(discount, basket)

        apply_discount if threshold_met?(effective_total)
      end

      def apply_changes_to_basket
        products.each { |product| add_free_product(product) }
      end

      private

      def threshold_met?(total)
        total.ex_vat >= discount.threshold && total.ex_vat.positive?
      end

      def apply_discount
        products.each { |product| make_product_free(product) }
        add_discount_line discount_line if discount_line.name.present?
      end

      def products
        @products ||= discount.products
      end

      def add_free_product(product)
        return if BasketItem.exists?(basket_id: basket.id, product_id: product.id)
        basket.basket_items << BasketItem.new(product_id: product.id, quantity: 1, reward: true)
      end

      def make_product_free(product)
        if discount_line.name.present?
          discount_line.name += " & #{product.name}"
        else
          discount_line.name = "Free #{product.name}"
        end
        discount_line.price_adjustment -= product.price_ex_tax
        discount_line.tax_adjustment -= product.tax_amount
      end

      def discount_line
        @discount_line ||= DiscountLine.new(
          discount,
          calculator: self,
          mutually_exclusive_with: [:free_products].to_set
        )
      end
    end
  end
end
