# frozen_string_literal: true

require "rails_helper"

# These talk to Stripe for real, in test mode, and are excluded from the
# default suite. Run them with bin/full-network-access-test.
#
# Every other Stripe spec stubs HTTP with WebMock, which accepts whatever
# parameters we hand it. That means the suite says nothing about whether Stripe
# agrees, and the gem pins the API version it sends on every request, so a
# version bump can change the answer without a line of our code changing.
#
# So these assert the one thing WebMock cannot: that the parameters we send are
# the parameters Stripe accepts, at the API version the gem currently pins.
# Run them before merging a stripe gem update.
module Payments
  RSpec.describe "Stripe API parameters", :full_network_access do
    # Order totals are derived, so a created order totals zero however the
    # factory is called, and Stripe rejects a zero amount before it looks at
    # anything else.
    let(:order) do
      FactoryBot.create(:order).tap do |o|
        o.update_column(:total, 12.34)
      end
    end

    it "uses a test mode key, so nothing here touches live data" do
      expect(::Stripe.api_key).to start_with("sk_test_")
    end

    describe "the mobile payment intent" do
      it "is accepted with the parameters StripePaymentIntent sends" do
        intent = StripePaymentIntent.new(
          order: order, payment_method: nil, idempotency_key: SecureRandom.uuid
        ).create_mobile_intent

        expect(intent.id).to start_with("pi_")
        expect(intent.amount).to eq 1234
        expect(intent.currency).to eq "gbp"
      end
    end

    describe "the web checkout card payment" do
      # The checkout path creates and confirms at once, with manual
      # confirmation. pm_card_visa is Stripe's test card that always succeeds.
      it "is confirmed and recorded as a payment" do
        intent = StripePaymentIntent.new(
          order: order, payment_method: "pm_card_visa", idempotency_key: SecureRandom.uuid
        )

        intent.attempt

        expect(intent.error).to be_nil
        expect(intent.status).to eq "succeeded"
        expect(intent.payment).to be_persisted
        expect(intent.payment.transaction_id).to start_with("pi_")
      end

      it "is retrieved and confirmed by ID when the client confirms first" do
        created = StripePaymentIntent.new(
          order: order, payment_method: "pm_card_visa", idempotency_key: SecureRandom.uuid
        ).create_mobile_intent

        intent = StripePaymentIntent.new(
          order: order, payment_method: nil, payment_intent_id: created.id,
          idempotency_key: SecureRandom.uuid
        )
        intent.attempt
        expect(intent.requires_confirmation?).to eq true

        intent.confirm
        expect(intent.status).to eq "succeeded"
      end
    end

    describe "saving a card to a Stripe customer" do
      it "creates a customer with the payment method, then attaches another" do
        customer = StripeCustomer.new(order)

        customer.add_payment_method("pm_card_visa")
        expect(order.reload.stripe_customer_id).to start_with("cus_")

        attached = customer.add_payment_method("pm_card_mastercard")
        expect(attached.customer).to eq order.stripe_customer_id
      end

      it "pays with the customer's saved card" do
        customer = StripeCustomer.new(order)
        customer.add_payment_method("pm_card_visa")
        payment_method = ::Stripe::PaymentMethod.list(customer: customer.customer_id, type: "card").first

        intent = StripePaymentIntent.new(
          order: order, payment_method: payment_method.id, customer: customer,
          idempotency_key: SecureRandom.uuid, stored: true
        )
        intent.attempt

        expect(intent.error).to be_nil
        expect(intent.status).to eq "succeeded"
        expect(intent.payment.stored).to eq true
      end
    end
  end
end
