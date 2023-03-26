# frozen_string_literal: true

require "rails_helper"

module Payments
  RSpec.describe StripePaymentIntent do
    describe "#attempt" do
      let(:status) { 200 }
      let(:response_body) { {"id" => "ch_1BoD8YBfGbSkFF2fUTuzh58G", "status" => "succeeded"}.to_json }

      def stub_stripe
        stub_request(:post, "https://api.stripe.com/v1/payment_intents")
          .with(
            body: {
              amount: "1055",
              confirm: true,
              confirmation_method: "manual",
              currency: "gbp",
              description: "400000",
              payment_method: "pm_123",
              metadata: {
                ignore_webhook: true
              }
            }
          )
          .to_return(
            status: status,
            body: response_body,
            headers: {}
          )
      end

      it "creates a Stripe payment intent" do
        stub = stub_stripe

        order = instance_double(
          Order, total: 10.55, order_number: "400000", payment_received?: false
        )
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_method: "pm_123", idempotency_key: "idem"
        )

        intent.attempt

        expect(stub).to have_been_requested
      end

      context "when order is already paid" do
        let(:order) do
          instance_double(
            Order, total: 10.55, order_number: "400000", payment_received?: true
          )
        end

        it "does not charge" do
          stub = stub_stripe

          intent = Payments::StripePaymentIntent.new(
            order: order, payment_method: "pm_123", idempotency_key: "idem"
          )

          intent.attempt

          expect(stub).not_to have_been_requested
        end
      end

      it "creates a charge with provided Stripe customer" do
        stub = stub_request(:post, "https://api.stripe.com/v1/payment_intents")
          .with(
            body: {
              amount: "1055",
              confirm: true,
              confirmation_method: "manual",
              currency: "gbp",
              customer: "cus_BJ7t3f3dD5YaVQ",
              description: "400000",
              payment_method: "pm_123",
              metadata: {
                ignore_webhook: true
              }
            }
          )
          .to_return(
            status: 200,
            body: response_body,
            headers: {}
          )
        customer = instance_double(
          Payments::StripeCustomer, customer_id: "cus_BJ7t3f3dD5YaVQ"
        )
        order = instance_double(
          Order, total: 10.55, order_number: "400000", payment_received?: false
        )
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_method: "pm_123",
          idempotency_key: "idem", customer: customer
        )

        intent.attempt

        expect(stub).to have_been_requested
      end

      it "creates a payment" do
        stub_stripe
        order = instance_double(
          Order, total: 10.55, order_number: "400000", payment_received?: false
        )
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_method: "pm_123", idempotency_key: "idem"
        )

        intent.attempt

        expect(Payment.count).to eq 1
        payment = Payment.last
        expect(payment.accepted?).to be_truthy
        expect(payment.amount).to eq 10.55
        expect(payment.cart_id).to eq "400000"
        expect(JSON.parse(payment.raw_auth_message))
          .to eq JSON.parse(response_body)
        expect(payment.service_provider).to eq "Stripe Web"
        expect(payment.transaction_id).to eq "ch_1BoD8YBfGbSkFF2fUTuzh58G"
        expect(payment.stored?).to be_falsey
      end

      it "creates a payment with the initialized stored value" do
        stub_stripe
        order = instance_double(
          Order, total: 10.55, order_number: "400000", payment_received?: false
        )
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_method: "pm_123", idempotency_key: "idem", stored: true
        )

        intent.attempt

        expect(Payment.count).to eq 1
        payment = Payment.last
        expect(payment.stored?).to be_truthy
      end

      shared_examples_for "an Apple Pay recorder" do
        it "records as an Apple Pay payment" do
          stub_stripe
          order = instance_double(
            Order, total: 10.55, order_number: "400000", payment_received?: false
          )
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_method: "pm_123", idempotency_key: "idem"
          )

          intent.attempt

          payment = Payment.last
          expect(payment.apple_pay).to be_truthy
        end

        it "sets stored as true (regardless of what it was initialized with)" do
          stub_stripe
          order = instance_double(
            Order, total: 10.55, order_number: "400000", payment_received?: false
          )
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_method: "pm_123", idempotency_key: "idem"
          )

          intent.attempt

          payment = Payment.last
          expect(payment.stored?).to be_truthy
        end
      end

      context "when paid by Apple Pay with direct source" do
        let(:response_body) {
          {
            "id" => "ch_1BoD8YBfGbSkFF2fUTuzh58G",
            "source" => {
              "tokenization_method" => "apple_pay"
            },
            :status => "succeeded"
          }.to_json
        }

        it_behaves_like "an Apple Pay recorder"
      end

      context "when paid by Apple Pay with card using wallet" do
        let(:response_body) {
          {
            "id" => "pi_1BoD8YBfGbSkFF2fUTuzh58G",
            :source => nil,
            "charges" => {
              "object" => "list",
              :has_more => false,
              :total_count => 1,
              "data" => [
                {
                  :id => "ch_1GSkxKBfGbSkFF2fCEzc1fFV",
                  :object => "charge",
                  "payment_method_details" => {
                    "card" => {
                      "wallet" => {
                        "apple_pay" => {},
                        "dynamic_last4" => "4242",
                        "type" => "apple_pay"
                      }
                    }
                  }
                }
              ]
            },
            "status" => "succeeded"
          }.to_json
        }

        it_behaves_like "an Apple Pay recorder"
      end

      context "when not paid by Apple Pay" do
        it "does not record as an Apple Pay payment" do
          stub_stripe
          order = instance_double(
            Order, total: 10.55, order_number: "400000", payment_received?: false
          )
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_method: "pm_123", idempotency_key: "idem"
          )

          intent.attempt

          payment = Payment.last
          expect(payment.apple_pay).to be_falsey
        end
      end

      it "allows overriding of the payment service provider" do
        stub_stripe
        order = instance_double(
          Order, total: 10.55, order_number: "400000", payment_received?: false
        )
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_method: "pm_123", idempotency_key: "idem"
        )

        intent.attempt(service_provider: "Stripe Mobile")

        expect(Payment.last.service_provider).to eq "Stripe Mobile"
      end

      shared_examples_for "an error handler" do
        let(:intent) do
          Payments::StripePaymentIntent.new(
            order: order, payment_method: "pm_123", idempotency_key: "idem"
          )
        end

        before do
          stub_stripe
          intent.attempt
        end

        it "does not create a payment" do
          expect(Payment.count).to be_zero
        end

        it "sets an error object" do
          expect(intent.error).to be_present
        end

        it "adds an order comment to the order" do
          expect(order.order_comments.length).to eq 1
          expect(order.order_comments.first.comment).to eq "Stripe Web " \
          "payment failed: #{message}"
        end
      end

      context "when attempt fails (CardError)" do
        let(:message) { "The zip code you supplied failed validation." }
        let(:status) { 402 }
        let(:response_body) do
          {
            "error" => {
              "charge" => "ch_1BoD8YBfGbSkFF2fUTuzh58G",
              "type" => "card_error",
              "message" => message
            }
          }.to_json
        end
        let(:order) do
          FactoryBot.build(
            :order,
            total: 10.55, order_number: "400000",
            status: Enums::PaymentStatus::WAITING_FOR_PAYMENT
          )
        end

        it_behaves_like "an error handler"
      end

      context "when attempt fails (InvalidRequestError)" do
        let(:message) { "Amount must be at least £0.30 gbp" }
        let(:status) { 400 }
        let(:response_body) do
          {
            "error" => {
              "code" => "amount_too_small",
              "type" => "invalid_request_error",
              "param" => "amount",
              "message" => message
            }
          }.to_json
        end
        let(:order) do
          FactoryBot.build(
            :order,
            total: 10.55, order_number: "400000",
            status: Enums::PaymentStatus::WAITING_FOR_PAYMENT
          )
        end

        it_behaves_like "an error handler"
      end

      context "when idempotency key is re-used (IdempotencyError)" do
        let(:message) { "Keys for idempotent requests can only be used..." }
        let(:status) { 400 }
        let(:response_body) do
          {
            "error" => {
              "type" => "idempotency_error",
              "message" => message
            }
          }.to_json
        end
        let(:order) do
          FactoryBot.build(
            :order,
            total: 10.55, order_number: "400000",
            status: Enums::PaymentStatus::WAITING_FOR_PAYMENT
          )
        end

        it_behaves_like "an error handler"
      end

      context "when idempotency key is re-used (APIError)" do
        let(:message) { "There is currently another in-progress request..." }
        let(:status) { 500 }
        let(:response_body) do
          {
            "error" => {
              "type" => "idempotency_error",
              "message" => message
            }
          }.to_json
        end
        let(:order) do
          FactoryBot.build(
            :order,
            total: 10.55, order_number: "400000",
            status: Enums::PaymentStatus::WAITING_FOR_PAYMENT
          )
        end

        it_behaves_like "an error handler"
      end
    end

    describe "#confirm" do
      let(:status) { 200 }
      let(:response_body) { {"id" => "pi_123", "status" => "succeeded"}.to_json }
      def stub_stripe
        stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_123/confirm")
          .with(
            body: {}
          )
          .to_return(
            status: status,
            body: response_body,
            headers: {}
          )
      end

      it "confirms an existing payment intent" do
        stub = stub_stripe
        order = instance_double(Order, total: 10.55, order_number: "400000")
        intent = Payments::StripePaymentIntent.new(
          order: order, payment_intent_id: "pi_123", payment_method: nil, idempotency_key: "idem"
        )

        intent.confirm

        expect(stub).to have_been_requested
      end
    end

    describe "#create_webhook_payment" do
      context "when there is no existing payment" do
        it "creates a new payment" do
          order = instance_double(
            Order,
            total: BigDecimal("10.55"), order_number: "400000"
          )
          payment_intent = double(::Stripe::PaymentIntent, id: "pi_123", source: nil, charges: [], to_s: "{}")
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_intent: payment_intent, payment_method: nil, idempotency_key: "idem"
          )
          intent.create_webhook_payment
          expect(Payment.count).to eq 1
          payment = Payment.last
          expect(payment.order_id).to be_nil
          expect(payment.cart_id).to eq "400000"
          expect(payment.amount).to eq BigDecimal("10.55")
          expect(payment).to be_accepted
          expect(payment.service_provider).to eq StripePaymentIntent::STRIPE_WEBHOOK
          expect(payment.transaction_id).to eq "pi_123"
          expect(payment.raw_auth_message).to eq "{}"
        end

        it "returns the new payment" do
          order = instance_double(
            Order,
            total: BigDecimal("10.55"), order_number: "400000"
          )
          payment_intent = double(::Stripe::PaymentIntent, id: "pi_123", source: nil, charges: [], to_s: "{}")
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_intent: payment_intent, payment_method: nil, idempotency_key: "idem"
          )
          payment = intent.create_webhook_payment
          expect(payment).to eq Payment.last
        end
      end

      context "when there is an existing accepted payment" do
        before { FactoryBot.create(:payment, accepted: true, transaction_id: "pi_123") }

        it "does not create a duplicate payment" do
          order = instance_double(Order)
          payment_intent = double(::Stripe::PaymentIntent, id: "pi_123")
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_intent: payment_intent, payment_method: nil, idempotency_key: "idem"
          )
          intent.create_webhook_payment
          expect(Payment.count).to eq 1
        end

        it "returns nil" do
          order = instance_double(Order)
          payment_intent = double(::Stripe::PaymentIntent, id: "pi_123")
          intent = Payments::StripePaymentIntent.new(
            order: order, payment_intent: payment_intent, payment_method: nil, idempotency_key: "idem"
          )
          payment = intent.create_webhook_payment
          expect(payment).to be_nil
        end
      end
    end

    describe "#ignore_webhook?" do
      it "returns truthy when metadata includes 'ignore_webhook' = 'true'" do
        payment_intent = ::Stripe::PaymentIntent.construct_from(metadata: {ignore_webhook: "true"})
        intent = Payments::StripePaymentIntent.new(payment_intent: payment_intent, order: nil, payment_method: nil, idempotency_key: nil)
        expect(intent.ignore_webhook?).to be_truthy
      end

      it "returns falsey when metadata includes 'ignore_webhook' = 'false'" do
        payment_intent = ::Stripe::PaymentIntent.construct_from(metadata: {ignore_webhook: "false"})
        intent = Payments::StripePaymentIntent.new(payment_intent: payment_intent, order: nil, payment_method: nil, idempotency_key: nil)
        expect(intent.ignore_webhook?).to be_falsey
      end
    end
  end
end
