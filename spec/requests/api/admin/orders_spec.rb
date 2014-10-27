require 'rails_helper'

describe 'Admin orders API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    let(:orders)            { JSON.parse(response.body) }
    let(:num_orders)        { 1 }
    let(:page)              { nil }
    let(:page_size)         { nil }
    let(:processed)         { nil }
    let(:status)            { nil }
    let(:default_page_size) { 3 }

    # +more_setup+ lambda allows more setup in the outer before block.
    let(:more_setup)        { nil }

    before do
      # Reduce default page size for spec execution speed.
      allow_any_instance_of(Api::Admin::OrdersController)
        .to receive(:default_page_size)
        .and_return(default_page_size)

      num_orders.times do |x|
        FactoryGirl.create(
          :order,
          website_id: @website.id,
          user_id: FactoryGirl.create(:user).id,
          created_at: Date.today - x.days # affects ordering
        )
      end
      @order1 = Order.first
      @order2 = FactoryGirl.create(:order)

      more_setup.try(:call)

      get '/api/admin/orders', page: page, page_size: page_size,
        processed: processed, status: status
    end

    it 'returns orders for the website' do
      expect(orders['orders'].length).to eq 1
      order = orders['orders'][0]
      expect(order['id']).to eq @order1.id
      expect(order['href']).to eq api_admin_order_url(@order1)
      expect(order['order_number']).to eq @order1.order_number
      user = order['user']
      expect(user['id']).to eq @order1.user.id
      expect(user['href']).to eq api_admin_user_url(@order1.user)
      expect(order['email_address']).to eq @order1.email_address
      expect(order['total']).to         eq @order1.total.to_s
      expect(order['status']).to        eq @order1.api_status_description
    end

    it 'returns 200 OK' do
      expect(response.status).to eq 200
    end

    context 'with status filtered to waiting_for_payment' do
      let(:status) { 'waiting_for_payment' }

      it 'returns 1 order' do
        expect(orders['orders'].length).to eq 1
      end
    end

    context 'with status filtered to payment_received' do
      let(:status) { 'payment_received' }

      it 'returns 0 orders' do
        expect(orders['orders'].length).to eq 0
      end
    end

    context 'with processed set' do
      let!(:more_setup) {->{
        @processed_order = FactoryGirl.create(:order, website_id: @website.id,
          processed_at: Date.today - 1.day)
      }}

      context 'to true' do
        let(:processed) { true }

        it 'returns processed orders only' do
          expect(orders['orders'].length).to eq 1
          expect(orders['orders'][0]['id']).to eq @processed_order.id
        end
      end

      context 'to false' do
        let(:processed) { false }

        it 'returns unprocessed orders only' do
          expect(orders['orders'].length).to eq 1
          expect(orders['orders'][0]['id']).to eq Order.first.id
        end
      end
    end

    context 'with more orders than default page size' do
      let(:num_orders) { default_page_size + 1 }

      it 'returns limited orders' do
        expect(orders['orders'].length).to eq default_page_size
      end

      it 'states total count of orders' do
        expect(orders['count']).to eq num_orders
      end

      context 'with page_size matching number of orders' do
        let(:page_size) { num_orders }

        it 'returns all orders' do
          expect(orders['orders'].length).to eq num_orders
        end
      end

      context 'with page set to 2 and page_size set to 1' do
        let(:page)      { 2 }
        let(:page_size) { 1 }

        it 'returns the second order only' do
          expect(orders['orders'].length).to eq 1
          expect(orders['orders'][0]['id']).to eq Order.second.id
        end
      end
    end

    context 'with no orders' do
      let(:num_orders) { 0 }

      it 'returns 200 OK' do
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        expect(orders['orders'].length).to eq 0
      end
    end
  end

  describe 'GET show' do
    context 'when order found' do
      before do
        @order = FactoryGirl.create(:order, website_id: @website.id)
      end

      it 'returns 200 OK' do
        get api_admin_order_path(@order)
        expect(response.status).to eq 200
      end
    end

    context 'when no order' do
      it 'returns 404 Not Found' do
        get '/api/admin/orders/0'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    let(:country) { FactoryGirl.create(:country, website_id: @website.id) }
    let(:billing_address_line_1)  { SecureRandom.hex }
    let(:billing_country_id)      { country.id }
    let(:billing_postcode)        { SecureRandom.hex }
    let(:billing_town_city)       { SecureRandom.hex }
    let(:delivery_address_line_1) { SecureRandom.hex }
    let(:delivery_country_id)     { country.id }
    let(:delivery_postcode)       { SecureRandom.hex }
    let(:delivery_town_city)      { SecureRandom.hex }
    let(:email_address)           { "#{SecureRandom.hex}@example.org" }
    let(:payment_status)          { 'waiting_for_payment' }

    let(:basic_params) {{
      billing_address_line_1: billing_address_line_1,
      billing_country_id: billing_country_id,
      billing_postcode: billing_postcode,
      billing_town_city: billing_town_city,
      delivery_address_line_1: delivery_address_line_1,
      delivery_country_id: delivery_country_id,
      delivery_postcode: delivery_postcode,
      delivery_town_city: delivery_town_city,
      email_address: email_address,
      status: payment_status
    }}

    it 'inserts a new order into the website' do
      post '/api/admin/orders', order: basic_params
      expect(Order.find_by(basic_params.merge(website_id: @website.id, status: Order::WAITING_FOR_PAYMENT))).to be
    end

    it 'returns 422 if order cannot be created' do
      post '/api/admin/orders', order: {email_address: 'is not enough'}
      expect(status).to eq 422
    end
  end
end
