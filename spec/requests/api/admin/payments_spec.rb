require 'rails_helper'

describe 'Admin payments API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    before do
      @order1 = FactoryGirl.create(:order, website_id: @website.id)
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

      expect(payments['payments'].length).to eq 1
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
        @order = FactoryGirl.create(:order, website_id: @website.id)
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
end
