require 'rails_helper'

describe 'Admin payments API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    before do
      @order1 = FactoryGirl.create(:order)
      @payment1 = FactoryGirl.create(
        :payment,
        order_id: @order1.id,
        amount: 49.50,
        currency: 'GBP',
        accepted: true,
        service_provider: 'WorldPay',
        test_mode: false
      )
      @payment2 = FactoryGirl.create(:payment)
    end

    it 'returns payments for the website' do
      get '/api/admin/payments'

      payments = JSON.parse(response.body)

      expect(payments['payments'].length).to eq 2
      payment = payments['payments'][0]
      expect(payment['id']).to eq @payment1.id
      expect(payment['href']).to eq api_admin_payment_url(@payment1)
      expect(payment['amount']).to eq @payment1.amount.to_s
      expect(payment['currency']).to eq @payment1.currency
      expect(payment['accepted']).to eq @payment1.accepted
      expect(payment['service_provider']).to eq @payment1.service_provider
      expect(payment['test_mode']).to eq @payment1.test_mode
      expect(payment['created_at']).to be
      expect(payment['updated_at']).to be
      order = payment['order']
      expect(order['id']).to eq @order1.id
      expect(order['href']).to eq api_admin_order_url(@order1)
    end

    it 'returns 200 OK' do
      get '/api/admin/payments'
      expect(response.status).to eq 200
    end
  end

  context 'with no payments' do
    it 'returns 200 OK' do
      get '/api/admin/payments'
      expect(response.status).to eq 200
    end

    it 'returns an empty set' do
      get '/api/admin/payments'
      payments = JSON.parse(response.body)
      expect(payments['payments'].length).to eq 0
    end
  end

  describe 'GET show' do
    context 'when payment found' do
      before do
        @order = FactoryGirl.create(:order)
        @payment = FactoryGirl.create(:payment, order_id: @order.id)
      end

      it 'returns 200 OK' do
        get api_admin_payment_path(@payment)
        expect(response.status).to eq 200
      end
    end

    context 'when no payment' do
      it 'returns 404 Not Found' do
        get '/api/admin/payments/0'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order) }

    let(:order_id)    { order.id }

    # Optional attributes
    let(:raw_auth_message) { nil }

    before do
      post '/api/admin/payments', payment: {
        order_id: order_id,
        accepted: accepted,
        amount: amount,
        raw_auth_message: raw_auth_message,
        service_provider: service_provider,
      }
    end

    context 'with invalid order' do
      let(:accepted) { true }
      let(:amount) { 1.0 }
      let(:service_provider) { 'BACS' }
      let(:order_id) { order.id + 1 }

      it 'responds 422' do
        expect(response.status).to eq 422
      end

      it 'includes an error message in JSON' do
        expect(JSON.parse(response.body)).to eq ['Order does not exist.']
      end
    end

    context 'with valid attributes' do
      let(:accepted) { [true, false].sample }
      let(:amount) { 123.45 }
      let(:raw_auth_message) { 'Detailed tx info' }
      let(:service_provider) { 'BACS' }
      let(:payment) { order.reload.payments.first }

      it 'creates a payment with supplied attributes' do
        expect(payment).to be
        expect(payment.accepted).to eq accepted
        expect(payment.amount).to eq amount.to_s
        expect(payment.raw_auth_message).to eq raw_auth_message
        expect(payment.service_provider).to eq service_provider
      end

      it 'responds 200' do
        expect(response.status).to eq 200
      end

      context 'JSON response' do
        subject { JSON.parse(response.body) }

        it 'includes the id and href of the newly created resource' do
          expect(subject['payment']['id']).to eq payment.id
          expect(subject['payment']['href']).to eq api_admin_payment_url(payment)
        end
      end
    end
  end
end
