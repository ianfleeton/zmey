# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Stripe payment intents", type: :request do
  describe "POST /payments/stripe/payment_intents" do
    let(:order) do
      instance_double(
        Order,
        :waiting_for_payment? => true,
        :email_address => "billpayer@example.com",
        :stripe_customer_id => nil, :stripe_customer_id= => nil
      )
    end
    before { allow(Order).to receive(:current!).and_return(order) }

    let(:use_saved) { nil }

    def perform
      post(
        payments_stripe_payment_intents_path,
        params: {payment_method_id: "pm_123", idempotency_key: "idem", use_saved: use_saved}
      )
    end

    context "when customer is using previously saved card" do
      let(:use_saved) { "on" }
      it "attempts to charge the payment method, using customer and " \
      "idempotency key" do
        user = User.new
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user).and_return(user)
        customer = instance_double(Payments::StripeCustomer)
        allow(Payments::StripeCustomer).to receive(:new).with(user).and_return(customer)
        expect(Payments::StripePaymentIntent)
          .to receive(:new)
          .with(
            order: order, payment_intent_id: nil, payment_method: "pm_123", idempotency_key: "idem",
            customer: customer, stored: true
          )
          .and_return(
            instance_double(
              Payments::StripePaymentIntent, error: nil, payment: Payment.new
            ).as_null_object
          )
        perform
      end
    end

    context "when guest user" do
      let(:customer) do
        instance_double(Payments::StripeCustomer, add_payment_method: nil)
      end

      it "assigns the order stripe_customer_id from the session, reusing it " \
      "from a previous transaction" do
        stub_stripe_customer
        stub_stripe_payment_intent(error: nil, succeeded: true, requires_action: false)
        session = {stripe_customer_id: "cus_D2Fo0KNo9wAPmN"}
        allow_any_instance_of(ApplicationController)
          .to receive(:session).and_return(session)
        expect(order)
          .to receive(:stripe_customer_id=).with("cus_D2Fo0KNo9wAPmN")
        perform
      end

      it "sets the session stripe_customer_id from the order so that it can " \
      "be reused in a future transaction" do
        stub_stripe_customer
        stub_stripe_payment_intent(error: nil, succeeded: true, requires_action: false)
        session = {}
        allow_any_instance_of(ApplicationController)
          .to receive(:session).and_return(session)
        allow(order)
          .to receive(:stripe_customer_id).and_return("cus_D2Fo0KNo9wAPmN")
        perform
        expect(session[:stripe_customer_id]).to eq "cus_D2Fo0KNo9wAPmN"
      end

      it "adds the tokenised source to the new customer" do
        stub_stripe_customer
        stub_stripe_payment_intent(error: nil, succeeded: true, requires_action: false)
        expect(customer).to receive(:add_payment_method).with("pm_123")
        perform
      end

      it "charges the customer's newly added method" do
        stub_stripe_customer
        intent = instance_double(
          Payments::StripePaymentIntent, error: nil, succeeded?: true, requires_confirmation?: false, payment: Payment.new
        )
        expect(Payments::StripePaymentIntent)
          .to receive(:new)
          .with(
            order: order, payment_intent_id: nil, payment_method: "pm_123", customer: customer,
            idempotency_key: "idem", stored: false
          )
          .and_return(intent)
        expect(intent).to receive(:attempt)
        perform
      end

      def stub_stripe_customer
        allow(Payments::StripeCustomer).to receive(:new).and_return(customer)
      end

      def stub_stripe_payment_intent(error:, succeeded:, requires_action:, requires_confirmation: false)
        intent = instance_double(
          Payments::StripePaymentIntent,
          error: error, succeeded?: succeeded, requires_action?: requires_action, requires_confirmation?: requires_confirmation, attempt: nil, payment: Payment.new
        )
        allow(Payments::StripePaymentIntent).to receive(:new).and_return(intent)
        intent
      end

      context "when charge succeeds" do
        before do
          stub_stripe_customer
          stub_stripe_payment_intent(error: nil, succeeded: true, requires_action: false)
          perform
        end

        it "responds 200 OK" do
          expect(response.status).to eq 200
        end

        it "returns success in JSON" do
          expect(JSON.parse(response.body)).to eq({"success" => true})
        end
      end

      context "when charge fails" do
        before do
          stub_stripe_customer
          error = instance_double(Stripe::CardError, message: "Declined")
          stub_stripe_payment_intent(error: error, succeeded: false, requires_action: false)
          perform
        end

        it "responds 400" do
          expect(response.status).to eq 400
        end

        it "returns error in JSON" do
          expect(JSON.parse(response.body)).to eq({"error" => "Payment failed: Declined"})
        end
      end
    end
  end
end
