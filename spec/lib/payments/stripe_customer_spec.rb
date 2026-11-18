# frozen_string_literal: true

require "rails_helper"

module Payments
  RSpec.describe StripeCustomer do
    describe "#add_payment_method" do
      context "with an order that has no Stripe customer yet" do
        let(:order) { FactoryBot.create(:order, email_address: "buyer@example.org") }

        it "creates a customer with the order's email address and stores its ID" do
          stub = stub_request(:post, "https://api.stripe.com/v1/customers")
            .with(body: {email: "buyer@example.org", payment_method: "pm_123"})
            .to_return(status: 200, body: {id: "cus_123", object: "customer"}.to_json)

          StripeCustomer.new(order).add_payment_method("pm_123")

          expect(stub).to have_been_requested
          expect(order.reload.stripe_customer_id).to eq "cus_123"
        end
      end

      context "with an existing Stripe customer" do
        let(:user) { FactoryBot.create(:user, stripe_customer_id: "cus_123") }

        it "attaches the payment method to the customer" do
          stub_request(:get, "https://api.stripe.com/v1/customers/cus_123")
            .to_return(status: 200, body: {id: "cus_123", object: "customer"}.to_json)
          attach = stub_request(:post, "https://api.stripe.com/v1/payment_methods/pm_123/attach")
            .with(body: {customer: "cus_123"})
            .to_return(status: 200, body: {id: "pm_123", object: "payment_method", customer: "cus_123"}.to_json)

          StripeCustomer.new(user).add_payment_method("pm_123")

          expect(attach).to have_been_requested
        end
      end
    end

    describe "#payment_methods" do
      it "returns an empty list when there is no Stripe customer" do
        expect(StripeCustomer.new(FactoryBot.build(:user)).payment_methods).to eq []
      end

      it "wraps the customer's cards for display" do
        user = FactoryBot.create(:user, stripe_customer_id: "cus_123")
        stub_request(:get, "https://api.stripe.com/v1/payment_methods?customer=cus_123&type=card")
          .to_return(status: 200, body: {
            object: "list",
            has_more: false,
            data: [{
              id: "pm_123",
              object: "payment_method",
              type: "card",
              card: {brand: "visa", last4: "4242", exp_month: 8, exp_year: 2030}
            }]
          }.to_json)

        methods = StripeCustomer.new(user).payment_methods

        expect(methods.map(&:id)).to eq ["pm_123"]
        expect(methods.first.to_s).to eq "visa ending in 4242 expires 8/2030"
      end
    end
  end
end
