module Discounts
  extend ActiveSupport::Concern

  protected

    def session_contains_coupon?(coupon)
      return false if session[:coupons].nil?
      return session[:coupons].include? coupon
    end

    def remove_invalid_discounts
      return unless session[:coupons]

      session[:coupons].each do |coupon|
        discount = Discount.find_by(coupon: coupon)
        if !discount || !discount.currently_valid?
          session[:coupons].delete(coupon)
          flash[:now] = I18n.t('controllers.basket.remove_invalid_discounts.removed')
        end
      end
    end

    def calculate_discounts
      @discount_lines = Array.new
      Discount.all.each do |discount|
        if discount_authorized?(discount)
          if discount.reward_type.to_sym == :free_products
            discount_free_products(discount.product_group.products)
          elsif discount.reward_type.to_sym == :amount_off_order
            calculate_amount_off_order(discount)
          elsif discount.reward_type.to_sym == :percentage_off_order
            calculate_percentage_off_order(discount)
          elsif discount.reward_type.to_sym == :percentage_off
            calculate_percentage_off(discount)
          end
        end
      end
    end

    # Returns <tt>true</tt> if the discount doesn't require a coupon code or if
    # the customer has supplied the correct coupon code.
    def discount_authorized?(discount)
      discount.coupon.blank? || session_contains_coupon?(discount.coupon)
    end

    def discount_free_products products
      products.each do |product|
        @basket.basket_items.each do |basket_item|
          if product.id == basket_item.product_id
            discount_line = DiscountLine.new
            discount_line.name = 'Free ' + product.name
            discount_line.price_adjustment = -product.price_ex_tax
            discount_line.tax_adjustment = -product.tax_amount
            @discount_lines << discount_line
            break
          end
        end
      end
    end

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

    def calculate_amount_off_order(discount)
      effective_total = EffectiveTotal.new(discount, @basket)

      if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
        discount_line = DiscountLine.new
        discount_line.name = discount.name
        discount_line.price_adjustment = -discount.reward_amount / effective_total.tax_rate
        discount_line.tax_adjustment = - discount.reward_amount - discount_line.price_adjustment
        @discount_lines << discount_line
      end
    end

    def calculate_percentage_off_order(discount)
      effective_total = EffectiveTotal.new(discount, @basket)

      if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
        discount_line = DiscountLine.new
        discount_line.name = discount.name
        discount_line.price_adjustment = -(discount.reward_amount / 100.0) * effective_total.ex_tax
        discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * effective_total.tax_amount
        @discount_lines << discount_line
      end
    end

    def calculate_percentage_off(discount)
      @basket.basket_items.each do |basket_item|
        if discount.product_group.nil? || discount.product_group.products.include?(basket_item.product)
          discount_line = DiscountLine.new
          discount_line.name = "#{discount.name} - #{basket_item.product.name}"
          discount_line.price_adjustment = -(discount.reward_amount / 100.0) * basket_item.product.price_ex_tax
          discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * basket_item.product.tax_amount
          @discount_lines << discount_line
        end
      end
    end
end
