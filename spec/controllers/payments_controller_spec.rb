require "rails_helper"

RSpec.describe PaymentsController, type: :controller do
  include ActiveJob::TestHelper

  let(:accept_payment_on_account) { false }
  let(:website) do
    FactoryBot.create(
      :website,
      accept_payment_on_account: accept_payment_on_account,
      phone_number: "01234 567890"
    )
  end

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  CALLBACK_PARAMS = {
    Address1: "a1",
    Address2: "a2",
    Address3: "a3",
    Address4: "a4",
    Amount: "1000",
    City: "ct",
    CountryCode: "123",
    CrossReference: "xr",
    CurrencyCode: "456",
    CustomerName: "cn",
    Message: "msg",
    OrderDescription: "od",
    OrderID: "id",
    PostCode: "pc",
    PreviousMessage: "pm",
    PreviousStatusCode: "psc",
    State: "st",
    StatusCode: "0",
    TransactionDateTime: "sc",
    TransactionType: "tt"
  }

  describe "POST cardsave_callback" do
    let(:params) { CALLBACK_PARAMS }

    it "creates a new payment" do
      expect { post :cardsave_callback, params: params }.to change { Payment.count }.by(1)
    end
  end

  describe "#cardsave_plaintext_post" do
    let(:params) { CALLBACK_PARAMS }

    before do
      website.cardsave_pre_shared_key = "xyzzy"
      website.cardsave_merchant_id = "plugh"
      website.cardsave_password = "plover"

      post :cardsave_callback, params: params
    end

    it "interpolates cardsave settings and callback params in order" do
      expect(controller.send(:cardsave_plaintext_post)).to eq "PreSharedKey=xyzzy&MerchantID=plugh&Password=plover&StatusCode=0&Message=msg&PreviousStatusCode=psc&PreviousMessage=pm&CrossReference=xr&Amount=1000&CurrencyCode=456&OrderID=id&TransactionType=tt&TransactionDateTime=sc&OrderDescription=od&CustomerName=cn&Address1=a1&Address2=a2&Address3=a3&Address4=a4&City=ct&State=st&PostCode=pc&CountryCode=123"
    end
  end

  describe "#rbs_worldpay_callback" do
    context "with successful payment details" do
      let(:cartId) { "NO SUCH CART" }
      let(:params) {
        {
          amount: "12.34",
          callbackPW: "",
          cartId: cartId,
          transStatus: "Y"
        }
      }

      it "creates a new payment" do
        expect { post :rbs_worldpay_callback, params: params }.to change { Payment.count }.by(1)
      end

      context "with matching order" do
        let(:order) { FactoryBot.create(:order) }
        let(:cartId) { order.order_number }

        it "sets the order status to payment received" do
          post :rbs_worldpay_callback, params: params
          expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
        end
      end
    end
  end

  describe "on_account" do
    let(:order) { FactoryBot.create(:order) }

    before do
      cookies.signed[:order_id] = order_id
    end

    context "with an order" do
      let(:order_id) { order.id }

      context "website accepts payment on account" do
        let(:accept_payment_on_account) { true }

        it "sets the order payment status to PAYMENT_ON_ACCOUNT" do
          post :on_account
          expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
        end

        it "sends an order confirmation email" do
          finalizer = instance_double(Orders::Finalizer)
          expect(Orders::Finalizer)
            .to receive(:new)
            .with(website)
            .and_return(finalizer)
          expect(finalizer).to receive(:send_confirmation).with(order)
          post :on_account
        end

        it "redirects to receipt" do
          post :on_account
          expect(response).to redirect_to(controller: "orders", action: "receipt")
        end
      end

      context "website does not accept payment on account" do
        let(:accept_payment_on_account) { false }

        it "redirects to checkout" do
          post :on_account
          expect(response).to redirect_to(checkout_path)
        end
      end
    end

    context "without an order" do
      let(:order_id) { nil }

      it "redirects to checkout" do
        post :on_account
        expect(response).to redirect_to(checkout_path)
      end
    end
  end
end
