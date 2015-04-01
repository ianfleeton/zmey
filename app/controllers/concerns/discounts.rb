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
      calculator = Calculator.new(Discount.all, session[:coupons], @basket)
      calculator.calculate
      @discount_lines = calculator.discount_lines
    end
end
