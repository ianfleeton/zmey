# frozen_string_literal: true

# Provides a method to help round a total amount of money.
module TotalMoney
  extend ActiveSupport::Concern

  def total_money(amount)
    BigDecimal(amount).round(2)
  end
end
