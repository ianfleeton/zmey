module Payments
  class StripePaymentMethod
    def initialize(payment_method)
      @payment_method = payment_method
    end

    def id
      @payment_method.id
    end

    def to_s
      card = @payment_method.respond_to?(:card) ? @payment_method.card : @payment_method
      "#{card.brand} ending in #{card.last4} expires #{card.exp_month}/#{card.exp_year}"
    end
  end
end
