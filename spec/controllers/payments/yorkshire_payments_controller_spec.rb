require 'rails_helper'

RSpec.describe Payments::YorkshirePaymentsController, type: :controller do
  it { should route(:post, '/payments/yorkshire_payments/callback').to(action: :callback) }

  let(:merchant_id) { '000000' }
  before { FactoryGirl.create(:website, yorkshire_payments_merchant_id: merchant_id) }

  describe 'POST callback' do
    let(:default_params) {{
      currencyCode: '826',
      transactionUnique: 'ORDER-1234',
      transactionID: '12345678',
      cardTypeCode: '',
      cartType: '',
      responseCode: '0',
    }}
    let(:params) { default_params }
    let(:pre) { nil }

    let(:payment) { Payment.last }

    before do
      pre.try(:call)
      post :callback, params
    end

    it 'records the amount as 0' do
      expect(payment.amount).to eq '0'
    end

    it 'responds with status 200 OK' do
      expect(response.status).to eq 200
    end

    it 'responds with text "success"' do
      expect(response.body).to eq 'success'
    end

    it 'records the service provider' do
      expect(payment.service_provider).to eq 'Yorkshire Payments'
    end

    it 'records the currency' do
      expect(payment.currency).to eq '826'
    end

    it 'records the Yorkshire Payments merchant ID' do
      expect(payment.installation_id).to eq merchant_id
    end

    it 'records the order number' do
      expect(payment.cart_id).to eq 'ORDER-1234'
    end

    it 'records the transaction ID' do
      expect(payment.transaction_id).to eq '12345678'
    end

    context 'using a test merchant ID' do
      let(:merchant_id) { '101380' }

      it 'sets the test mode to true' do
        expect(payment.test_mode).to eq true
      end
    end

    context 'using a normal merchant ID' do
      let(:merchant_id) { '123456' }

      it 'sets the test mode to false' do
        expect(payment.test_mode).to eq false
      end
    end

    context 'successful transaction' do
      let(:params) {{
        amountReceived: '10.00',
        avscv2ResponseCode: '',
        responseCode: '0',
      }.merge(default_params)}

      it 'records the amount' do
        expect(payment.amount).to eq '10.00'
      end

      it 'creates an accepted payment' do
        expect(payment.accepted?).to eq true
      end

      it 'records a successful transaction status' do
        expect(payment.transaction_status).to be_truthy
      end

      context '#clean_up' do
        let(:pre) { -> { expect(controller).to receive(:clean_up) } }
        it 'assigns @payment and calls #clean_up' do
          expect(assigns(:payment)).to be_instance_of(Payment)
        end
      end
    end

    context 'failed transaction' do
      let(:params) {default_params.merge({
        responseCode: '5',
      })}

      it 'creates a rejected payment' do
        payment = Payment.last
        expect(payment.accepted?).to eq false
      end

      it 'records a failed transaction status' do
        expect(payment.transaction_status).to be_falsey
      end
    end
  end
end
