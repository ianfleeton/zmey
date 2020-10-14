# frozen_string_literal: true

module Orders
  class TaxStatus
    attr_reader :order

    delegate :billing_company, to: :order
    delegate :billing_country, to: :order
    delegate :delivery_country, to: :order
    delegate :vat_number, to: :order

    def initialize(order)
      @order = order
    end

    def zero_rated?
      billing_country && !billing_country.uk? && (
        zero_rated_eu_company? || zero_rated_rest_of_world?
      )
    end

    def zero_rated_eu_company?
      billing_country.in_eu? &&
        billing_country == delivery_country &&
        billing_company.present? &&
        vat_number.present?
    end

    def zero_rated_rest_of_world?
      !billing_country.in_eu? &&
        billing_country == delivery_country
    end
  end
end
