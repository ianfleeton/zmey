# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payments::PaypalController, type: :controller do
  let(:website) { FactoryBot.build(:website, paypal_test_mode: true) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  it do
    should route(:get, "/payments/paypal/auto_return").to(action: :auto_return)
  end

  describe "GET auto_return" do
    before do
      allow(controller).to receive(:pdt_notification_sync)
        .and_return(pdt_response)
    end

    let(:pdt_response) do
      {
        status: status,
        item_name: "",
        mc_gross: "0.00",
        mc_currency: "",
        address_name: "",
        address_street: "",
        address_city: "",
        address_state: "",
        address_zip: "",
        address_country_code: "",
        contact_phone: "",
        payer_email: "",
        payment_date: "06:45:01 Jun 23, 2015 PDT",
        txn_id: "5Z1250734065523781",
        raw_auth_message: "raw",
        payment_status: "Completed",
        charset: "utf-8"
      }
    end

    context "with successful PDT response" do
      let(:status) { "SUCCESS" }

      it "creates a new payment with accepted = true" do
        get :auto_return
        payment = Payment.last
        expect(payment).to be_accepted
        expect(payment.raw_auth_message).to eq "raw"
        expect(payment.transaction_id).to eq "5Z1250734065523781"
        expect(payment.transaction_time).to eq "06:45:01 Jun 23, 2015 PDT"
      end

      it "redirects to the receipt page" do
        get :auto_return
        expect(response).to redirect_to(receipt_orders_path)
      end

      it "sets a flash notice" do
        get :auto_return
        expect(flash[:notice]).to eq "Thank you for your payment. Your transaction has been completed and a receipt for your purchase has been emailed to you. You may log into your account at www.paypal.com/uk to view details of this transaction."
      end
    end

    context "with unsucessful PDT response" do
      let(:status) { "FAIL" }

      it "creates a payment with accepted = false" do
        get :auto_return
        payment = Payment.last
        expect(payment).not_to be_accepted
      end

      it "redirects to the basket" do
        get :auto_return
        expect(response).to redirect_to(basket_path)
      end

      it "sets a flash notice" do
        get :auto_return
        expect(flash[:notice]).to eq "We could not confirm your payment was successful. You may log into your account at www.paypal.com/uk to view details of this transaction."
      end
    end

    context "when PDF notification sync results in a SocketError" do
      let(:status) { "SUCCESS" }

      before do
        allow(controller).to receive(:pdt_notification_sync)
          .and_raise(SocketError.new("Failed to open TCP connection to www.paypal.com:443 (getaddrinfo: Name or service not known)"))
      end

      it "redirects to the basket" do
        get :auto_return
        expect(response).to redirect_to(basket_path)
      end

      it "sets a flash notice" do
        get :auto_return
        expect(flash[:notice]).to eq "Sorry, we could not communicate with PayPal to find out if your payment was successful. You may log into your account at www.paypal.com/uk to view details of this transaction."
      end
    end
  end

  describe "POST ipn_listener" do
    let(:params) do
      {
        "mc_gross" => "1.00",
        "protection_eligibility" => "Eligible",
        "address_status" => "confirmed",
        "payer_id" => "VQH62EAKETNVN",
        "tax" => "0.00",
        "address_street" => "1 Main Terrace",
        "payment_date" => "06:45:01 Jun 23, 2015 PDT",
        "payment_status" => payment_status,
        "charset" => "windows-1252",
        "address_zip" => "W12 4LQ",
        "first_name" => "test",
        "mc_fee" => "0.23",
        "address_country_code" => "GB",
        "address_name" => (+"Ruairi O\x92Sullivan").force_encoding("windows-1252"),
        "notify_version" => "3.8",
        # custom would usually be set to the order number, if set at all.
        # We set it to 'CUSTOM' here to differentiate its value in testing.
        "custom" => "CUSTOM",
        "payer_status" => "verified",
        "business" => "merchant@example.com",
        "address_country" => "United Kingdom",
        "address_city" => "Wolverhampton",
        "quantity" => "1",
        "verify_sign" =>
          "AnzPAvrf087BDaBIrtu.ICczwZ-gAY4..NHL19pjDaSY-bxUkRlJgK9H",
        "payer_email" => "buyer@example.org",
        "txn_id" => "0TH37164C80937821",
        "payment_type" => "instant",
        "last_name" => "buyer",
        "address_state" => "West Midlands",
        "receiver_email" => "merchant@example.com",
        "payment_fee" => "",
        "receiver_id" => "ETGX6AQ7GRB3L",
        "txn_type" => "web_accept",
        "item_name" => "20150623-8ST0",
        "mc_currency" => "GBP",
        "item_number" => "",
        "residence_country" => "GB",
        "test_ipn" => "1",
        "handling_amount" => "0.00",
        "transaction_subject" => "",
        "payment_gross" => "",
        "shipping" => "0.00",
        "ipn_track_id" => "21f2b2c41857e"
      }
    end
    let(:ipn_valid?) { nil }
    let(:payment_status) { "" }

    it "checks validity of the IPN message" do
      expected_params = params.dup
      expected_params["address_name"] = "Ruairi O\x92Sullivan"
      expect(controller).to receive(:ipn_valid?).with(hash_including(expected_params))
      post :ipn_listener, params: params
    end

    context "when PayPal post back cannot be reached" do
      before do
        http = instance_double(Net::HTTP, :use_ssl= => nil)
        allow(Net::HTTP)
          .to receive(:new)
          .with("www.sandbox.paypal.com", 443)
          .and_return(http)
        @error = SocketError.new
        allow(http)
          .to receive(:post)
          .and_raise(@error)
      end

      it "should respond 500" do
        post :ipn_listener, params: params
        expect(response.status).to eq 500
      end

      it "logs an error message" do
        expect(Rails.logger).to receive(:error).with(@error)
        post :ipn_listener, params: params
      end
    end

    context "when paypal sends dispute" do
      let(:params) do
        {
          "txn_type" => "new_case",
          "payment_date" => "04:51:56 Sep 23, 2020 PDT",
          "case_id" => "PP-D-85785153",
          "case_type" => "dispute",
          "business" => "admin@example.com",
          "verify_sign" => "A.-UecNL5hJyWLfqBV-1IjekrtvdA3KYWCCZSfSqSNcvHuhR.66vIeFe",
          "payer_email" => "example@gmail.com",
          "txn_id" => "7DJ67764AK8475733",
          "case_creation_date" => "10:51:44 Sep 28, 2020 PDT",
          "receiver_email" => "admin@example.com",
          "payer_id" => "SUNFGFM2LVUC6",
          "receiver_id" => "9FD3DLAA65YBJ",
          "reason_code" => "not_as_described",
          "custom" => order_number,
          "charset" => "windows-1252",
          "notify_version" => "3.9",
          "ipn_track_id" => "d1b443e67fa56"
        }
      end

      let(:order) { FactoryBot.create(:order) }
      let(:order_number) { order.order_number }

      it "adds an order comment" do
        post :ipn_listener, params: params
        comment = order.reload.order_comments.last
        expect(comment.comment).to eq "Order dispute received from PayPal for reason not_as_described"
      end

      it "does not create a payment" do
        post :ipn_listener, params: params
        expect(Payment.count).to eq 0
      end

      context "it cannot find an order" do
        let(:order_number) { nil }

        it "logs to the console" do
          expect(Rails.logger).to receive(:error).with "Recieved PayPal dispute and could not find an order to comment on. Case ID: PP-D-85785153"
          post :ipn_listener, params: params
        end
      end
    end

    context "when IPN valid" do
      before do
        allow(controller).to receive(:ipn_valid?).and_return(true)
      end

      it "records a payment" do
        post :ipn_listener, params: params
        payment = Payment.last
        expect(payment.amount).to eq 1
        expect(payment.cart_id).to eq "20150623-8ST0"
        expect(payment.currency).to eq "GBP"
        expect(payment.description).to eq "Web purchase"
        expect(payment.email).to eq "buyer@example.org"
        expect(payment.installation_id).to eq "merchant@example.com"
        expect(payment.name).to eq "Ruairi O’Sullivan"
        expect(payment.raw_auth_message).to start_with('{:address_city=>"Wolverhampton"')
        expect(payment.service_provider).to eq "PayPal (IPN)"
        expect(payment.transaction_id).to eq "0TH37164C80937821"
        expect(payment.transaction_time).to eq "06:45:01 Jun 23, 2015 PDT"
      end

      context "when PayPal sends a txn_type=cart response (buggy?)" do
        let(:params) do
          hash = super().merge(
            "num_cart_items" => "1",
            "txn_type" => "cart",
            "item_name1" => "345678"
          )
          hash.delete("item_name")
          hash
        end

        it "records the cart_id correctly from item_name1" do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.cart_id).to eq "345678"
        end
      end

      context "when PayPal sends item_name=Shopping Cart response (buggy?)" do
        let(:params) do
          super().merge(
            "custom" => "345678",
            "item_name" => "Shopping Cart"
          )
        end

        it "records the cart_id correctly from custom" do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.cart_id).to eq "345678"
        end
      end

      context "when payment_status is Completed" do
        let(:payment_status) { "Completed" }

        it "records the payment as accepted" do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.accepted?).to eq true
        end

        it "calls #finalize_order" do
          expect(controller).to receive(:finalize_order)
          post :ipn_listener, params: params
        end
      end

      context "when payment status is not Completed" do
        let(:payment_status) { "Pending" }

        it "records the payment as not accepted" do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.accepted?).to eq false
        end

        it "does not call #finalize_order" do
          expect(controller).not_to receive(:finalize_order)
          post :ipn_listener, params: params
        end
      end
    end
  end

  # rubocop:disable Performance/UnfreezeString
  describe "#pdt_notification_sync" do
    let(:body) do
      "
mc_gross=99.95
protection_eligibility=Eligible
address_status=unconfirmed
payer_id=WXYZ1ABCD23EF
tax=0.00
address_street=Etel\xE4inen
payment_date=08%3A34%3A16+May+04%2C+2015+PDT
payment_status=Completed
charset=windows-1252
address_zip=29900
first_name=A
mc_fee=1.23
address_country_code=FI
address_name=A+Buyer
custom=
payer_status=verified
business=merchant%40example.com
address_country=Finland
address_city=Merikarvia
quantity=1
payer_email=a.buyer%40example.com
txn_id=1234567890ABCDEFG
payment_type=instant
last_name=Buyer
address_state=Merikarvia
receiver_email=merchant%40example.com
payment_fee=
receiver_id=ABCDEF1234567
txn_type=web_accept
item_name=20150504-XXXX
mc_currency=GBP
item_number=
residence_country=FI
handling_amount=0.00
transaction_subject=
payment_gross=
shipping=0.00
      ".dup.force_encoding("windows-1252")
    end
    # rubocop:enable Performance/UnfreezeString

    before do
      allow(controller).to receive(:pdt_notification_sync_response_body)
        .and_return body
    end

    it "converts to UTF-8" do
      response = controller.send(:pdt_notification_sync, "x", "y")
      expect(response[:address_street]).to eq "Eteläinen"
    end
  end
end
