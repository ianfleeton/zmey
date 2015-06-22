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
