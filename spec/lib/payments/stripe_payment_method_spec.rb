# frozen_string_literal: true

require "rails_helper"

module Payments
  RSpec.describe StripePaymentMethod do
    describe "#to_s" do
      it "returns a description of a payment method type Card" do
        payment_method = double(::Stripe::Card, brand: "Visa", last4: "4242", exp_month: 12, exp_year: 2023)
        expect(StripePaymentMethod.new(payment_method).to_s).to eq "Visa ending in 4242 expires 12/2023"
      end

      it "returns a description of a payment method" do
        card = double(::Stripe::StripeObject, brand: "Visa", last4: "4242", exp_month: 12, exp_year: 2023)
        payment_method = double(::Stripe::PaymentMethod, card: card)
        expect(StripePaymentMethod.new(payment_method).to_s).to eq "Visa ending in 4242 expires 12/2023"
      end
    end
  end
end
