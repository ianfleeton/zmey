# frozen_string_literal: true

module Checkout
  # Card testers place tiny orders to check stolen cards cheaply, so anything
  # with goods to pay for must reach a minimum value. Free orders are
  # unaffected and shipping is not counted. Administrators are exempt.
  module MinimumOrderValue
    AMOUNT = BigDecimal(2)

    # +shopping+ is a Basket or Order.
    def self.below?(shopping)
      total = shopping.total_for_shipping
      total.positive? && total < AMOUNT
    end

    def self.message
      I18n.t(
        "controllers.checkout.below_minimum_order_value",
        amount: ActiveSupport::NumberHelper.number_to_currency(AMOUNT, unit: "£")
      )
    end
  end
end
