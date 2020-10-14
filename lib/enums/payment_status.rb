module Enums
  class PaymentStatus
    ORDER_NOT_PLACED = 0
    WAITING_FOR_PAYMENT = 1
    PAYMENT_RECEIVED = 2
    PAYMENT_ON_ACCOUNT = 3
    QUOTE = 4
    PRO_FORMA = 5
    PAY_BY_PHONE = 6
    CANCELED = 7
    NEEDS_SHIPPING_QUOTE = 8

    VALUES = (ORDER_NOT_PLACED..NEEDS_SHIPPING_QUOTE)

    def initialize(status)
      if VALUES.include?(status)
        @status = status
      else
        raise "Invalid value of status"
      end
    end

    def to_i
      @status
    end

    # Describes the +status+ attribute in English.
    def to_s
      {
        ORDER_NOT_PLACED => "Order not placed",
        WAITING_FOR_PAYMENT => "Waiting for payment",
        PAYMENT_RECEIVED => "Payment received",
        PAYMENT_ON_ACCOUNT => "Payment on account",
        QUOTE => "Quote",
        PRO_FORMA => "Pro forma invoice",
        PAY_BY_PHONE => "Paying by phone",
        CANCELED => "Canceled",
        NEEDS_SHIPPING_QUOTE => "Needs shipping quote"
      }[@status]
    end

    # Returns a string for use in the REST API.
    def to_api
      to_s.downcase.tr(" ", "_")
    end

    # Returns one of VALUES matching the +status+ string from
    # an API request. Complements PaymentStatus#to_api.
    #
    #   PaymentStatus.from_api('payment_received') # => PAYMENT_RECEIVED
    def self.from_api(string)
      PaymentStatus.new({
        "waiting_for_payment" => WAITING_FOR_PAYMENT,
        "payment_received" => PAYMENT_RECEIVED,
        "payment_on_account" => PAYMENT_ON_ACCOUNT,
        "quote" => QUOTE
      }[string])
    end
  end
end
