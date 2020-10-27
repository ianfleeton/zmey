# frozen_string_literal: true

module DiscountConcerns
  extend ActiveSupport::Concern

  protected

  def discount_lines
    @discount_lines ||= recalculate_discounts(allow_modify_basket: false)
  end

  def recalculate_discounts(allow_modify_basket:)
    @discount_lines = calculate_discounts(allow_modify_basket: allow_modify_basket, basket: basket)
  end

  def calculate_discounts(allow_modify_basket:, basket:)
    calculator = Discounts::Calculator.new(Discount.currently_valid(code: session[:discount_code]), basket)
    calculator.calculate
    if allow_modify_basket
      calculator.apply_changes_to_basket
    end
    calculator.discount_lines
  end
end
