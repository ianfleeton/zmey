module Payments
  # Creates a random string to be used in APIs such as Stripe that support
  # idempotency on requests that would otherwise unwanted cause side effects
  # if called more than once.
  class IdempotencyKey
    def initialize
      @key = SecureRandom.hex[0...16]
    end

    def to_s
      @key
    end
  end
end
