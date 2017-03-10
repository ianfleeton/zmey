require 'rails_helper'

RSpec.describe Payments::UpgAtlasController, type: :controller do
  it { should route(:get, '/payments/upg_atlas/callback').to(action: :callback) }

  before { FactoryGirl.create(:website, upg_atlas_sh_reference: 'SH1234') }

  describe 'GET callback' do
    let(:default_params) {{
      transactionamount: '10.00',
      transactioncurrency: 'GBP',
      cardholdersname: 'Alice',
      cardholdersemail: 'alice@example.org',
      cardholderstelephonenumber: '01234 567890',
      ordernumber: 'ORDER-1234',
      transactiontime: '2015-01-01 00:00:01',
    }}
    let(:params) { default_params }
    let(:pre) { nil }

    let(:payment) { Payment.last }

    before do
      pre.try(:call)
      get :callback, params: params
    end

    it 'responds with status 200 OK' do
      expect(response.status).to eq 200
    end

    it 'responds with text "success"' do
      expect(response.body).to eq 'success'
    end

    it 'records the service provider' do
      expect(payment.service_provider).to eq 'UPG Atlas'
    end

    it 'records the amount' do
      expect(payment.amount).to eq '10.00'
    end

    it 'records the currency' do
      expect(payment.currency).to eq 'GBP'
    end

    it 'records the UPG account reference' do
      expect(payment.installation_id).to eq 'SH1234'
    end

    it "records the cardholder's name" do
      expect(payment.name).to eq 'Alice'
    end

    it "records the cardholder's email" do
      expect(payment.email).to eq 'alice@example.org'
    end

    it "records the cardholder's phone number" do
      expect(payment.telephone).to eq '01234 567890'
    end

    it 'records the order number' do
      expect(payment.cart_id).to eq 'ORDER-1234'
    end

    it 'sets the test mode to false' do
      expect(payment.test_mode).to eq false
    end

    it 'records the transaction time' do
      expect(payment.transaction_time).to eq '2015-01-01 00:00:01'
    end

    context 'successful transaction' do
      let(:params) {{
        transactionnumber: '12345678',
        cv2avsresult: '',
        upgcardtype: '',
        upgauthcode: '',
      }.merge(default_params)}

      it 'creates an accepted payment' do
        expect(payment.accepted?).to eq true
      end

      it 'records a successful transaction status' do
        expect(payment.transaction_status).to be_truthy
      end

      it 'records the transaction number' do
        expect(payment.transaction_id).to eq '12345678'
      end
    end

    context 'failed transaction' do
      let(:params) {{
        transactionnumber: '-1',
        failurereason: 'FAIL'
      }.merge(default_params)}

      it 'creates a rejected payment' do
        payment = Payment.last
        expect(payment.accepted?).to eq false
      end

      it 'records a failed transaction status' do
        expect(payment.transaction_status).to be_falsey
      end
    end

    context 'test transaction' do
      let(:params) {{
        transactiontype: 'test'
      }.merge(default_params)}

      it 'sets test mode to true' do
        expect(payment.test_mode).to eq true
      end
    end

    context 'sh_reason is testing (also a test transaction)' do
      let(:params) {{
        sh_reason: 'testing'
      }.merge(default_params)}

      it 'sets test mode to true' do
        expect(payment.test_mode).to eq true
      end
    end
  end
end
