# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PayPal", type: :request do
  describe "GET /payments/paypal/new" do
    let(:order) { FactoryBot.create(:order) }
    let(:fingerprint) { Security::OrderFingerprint.new(order) }

    def cookies
      ActionDispatch::Request.new(request.env).cookie_jar
    end

    before do
      get "/payments/paypal/#{order.order_number}/#{fingerprint}/new"
    end

    context "when fingerprint is wrong" do
      let(:fingerprint) { "x" }
      it { should redirect_to root_path }
      it "sets a flash alert" do
        expect(flash[:alert]).to eq "The payment link is no longer valid"
      end
    end

    context "when order is already paid" do
      it { should redirect_to root_path }
      it "sets a flash alert" do
        expect(flash[:alert]).to eq "This order is fully paid!"
      end
    end

    context "when order is unpaid" do
      let(:order) { FactoryBot.create(:order, :unpaid) }

      it "sets cookies.signed[:order_id]" do
        expect(cookies.signed[:order_id]).to eq order.id
      end

      it "renders a PayPal form" do
        assert_select(
          "input[type=hidden][name='amount'][value='#{order.total}']"
        )
      end
    end
  end
end
