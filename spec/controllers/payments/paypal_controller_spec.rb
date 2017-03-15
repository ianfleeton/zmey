require 'rails_helper'

RSpec.describe Payments::PaypalController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  it { should route(:get, '/payments/paypal/auto_return').to(action: :auto_return) }

  describe 'GET auto_return' do
    before do
      allow(controller).to receive(:pdf_notification_sync).and_return(pdt_response)
    end

    context 'with successful PDT response' do
      let(:pdt_response) {{
        status: 'SUCCESS',
        item_name: '',
        mc_gross: '0.00',
        mc_currency: '',
        address_name: '',
        address_street: '',
        address_city: '',
        address_state: '',
        address_zip: '',
        address_country_code: '',
        contact_phone: '',
        payer_email: '',
        txn_id: '',
        payment_date: '',
        raw_auth_message: '',
        payment_status: 'Completed',
        charset: 'utf-8',
      }}

      it 'redirects to the PayPal confirmation page' do
        get :auto_return
        expect(response).to redirect_to(payments_paypal_confirmation_path)
      end
    end
  end

  describe 'GET confirmation' do
    it 'works' do
      get :confirmation
    end
  end

  describe 'POST ipn_listener' do
    let(:params) {{
      'mc_gross' => '1.00',
      'protection_eligibility' => 'Eligible',
      'address_status' => 'confirmed',
      'payer_id' => 'VQH62EAKETNVN',
      'tax' => '0.00',
      'address_street' => '1 Main Terrace',
      'payment_date' => '06:45:01 Jun 23, 2015 PDT',
      'payment_status' => payment_status,
      'charset' => 'windows-1252',
      'address_zip' => 'W12 4LQ',
      'first_name' => 'test',
      'mc_fee' => '0.23',
      'address_country_code' => 'GB',
      'address_name' => 'test buyer',
      'notify_version' => '3.8',
      'custom' => '',
      'payer_status' => 'verified',
      'business' => 'merchant@example.com',
      'address_country' => 'United Kingdom',
      'address_city' => 'Wolverhampton',
      'quantity' => '1',
      'verify_sign' => 'AnzPAvrf087BDaBIrtu.ICczwZ-gAY4..NHL19pjDaSY-bxUkRlJgK9H',
      'payer_email' => 'buyer@example.org',
      'txn_id' => '0TH37164C80937821',
      'payment_type' => 'instant',
      'last_name' => 'buyer',
      'address_state' => 'West Midlands',
      'receiver_email' => 'merchant@example.com',
      'payment_fee' => '',
      'receiver_id' => 'ETGX6AQ7GRB3L',
      'txn_type' => 'web_accept',
      'item_name' => '20150623-8ST0',
      'mc_currency' => 'GBP',
      'item_number' => '',
      'residence_country' => 'GB',
      'test_ipn' => '1',
      'handling_amount' => '0.00',
      'transaction_subject' => '',
      'payment_gross' => '',
      'shipping' => '0.00',
      'ipn_track_id' => '21f2b2c41857e',
    }}
    let(:ipn_valid?) { nil }
    let(:payment_status) { nil }

    before do
      allow(controller).to receive(:ipn_valid?).and_return(ipn_valid?)
    end

    it 'checks validity of the IPN message' do
      expect(controller).to receive(:ipn_valid?)
      post :ipn_listener, params: params
    end

    context 'when IPN valid' do
      let(:ipn_valid?) { true }
      it 'records a payment' do
        post :ipn_listener, params: params
        payment = Payment.last
        expect(payment.amount).to eq 1.0
        expect(payment.cart_id).to eq '20150623-8ST0'
        expect(payment.currency).to eq 'GBP'
        expect(payment.description).to eq 'Web purchase'
        expect(payment.email).to eq 'buyer@example.org'
        expect(payment.installation_id).to eq 'merchant@example.com'
        expect(payment.service_provider).to eq 'PayPal (IPN)'
      end

      context 'when payment_status is Completed' do
        let(:payment_status) { 'Completed' }

        it 'records the payment as accepted' do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.accepted?).to eq true
        end

        it 'calls #clean_up' do
          expect(controller).to receive(:clean_up)
          post :ipn_listener, params: params
        end
      end

      context 'when payment status is not Completed' do
        let(:payment_status) { 'Pending' }

        it 'records the payment as not accepted' do
          post :ipn_listener, params: params
          payment = Payment.last
          expect(payment.accepted?).to eq false
        end

        it 'does not call #clean_up' do
          expect(controller).not_to receive(:clean_up)
          post :ipn_listener, params: params
        end
      end
    end
  end

  describe '#pdt_notification_sync' do
    let(:body) {
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
      ".force_encoding('windows-1252') }

    before do
      allow(controller).to receive(:pdt_notification_sync_response_body).and_return body
    end

    it 'converts to UTF-8' do
      response = controller.send(:pdt_notification_sync, 'x', 'y')
      expect(response[:address_street]).to eq 'Eteläinen'
    end
  end
end
