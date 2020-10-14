# frozen_string_literal: true

module Security
  class OrderFingerprint
    attr_reader :order

    delegate :to_s, to: :fingerprint
    delegate :hash, to: :fingerprint

    def initialize(order)
      @order = order
    end

    def ==(other)
      fingerprint == other
    end

    private

    def fingerprint
      Fingerprint.new(order, attributes)
    end

    def attributes
      [
        :billing_full_name,
        :billing_postcode,
        :created_at,
        :email_address,
        :order_number,
        :total
      ]
    end
  end
end
