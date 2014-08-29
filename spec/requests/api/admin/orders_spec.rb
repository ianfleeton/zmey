require 'rails_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin orders API' do
  before do
    prepare_api_website
    allow_any_instance_of(Api::Admin::AdminController).to receive(:authenticated_api_key).and_return(@api_key)
  end

  describe 'GET index' do
    before do
      @order1 = FactoryGirl.create(:order, website_id: @website.id, user_id: FactoryGirl.create(:user).id)
      @order2 = FactoryGirl.create(:order)
    end

    it 'returns orders for the website' do
      get 'api/admin/orders'

      orders = JSON.parse(response.body)

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
    end

    it 'returns 200 OK' do
      get 'api/admin/orders'
      expect(response.status).to eq 200
    end
  end

  context 'with no orders' do
    it 'returns 200 OK' do
      get 'api/admin/orders'
      expect(response.status).to eq 200
    end

    it 'returns an empty set' do
      get 'api/admin/orders'
      orders = JSON.parse(response.body)
      expect(orders['orders'].length).to eq 0
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
        get 'api/admin/orders/0'
        expect(response.status).to eq 404
      end
    end
  end
end
