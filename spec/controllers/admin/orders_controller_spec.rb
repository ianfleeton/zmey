require 'spec_helper'

describe Admin::OrdersController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_order(stubs={})
    @mock_order ||= mock_model(Order, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  context 'when admin or manager' do
    before { controller.stub(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      context 'with no user supplied' do
        it 'assigns all orders for the current website to @orders' do
          website.should_receive(:orders).and_return :some_orders
          get 'index'
          assigns(:orders).should eq :some_orders
        end
      end

      context 'with user supplied' do
        it 'assigns all orders for the supplied user to @orders' do
          u = User.create!(email: 'user@example.org', name: 'Alice', password: 'secret')
          Order.create!(user_id: u.id, email_address: 'user@example.org', address_line_1: 'a', town_city: 'tc', postcode: 'pc', website_id: website.id)
          Order.create!(user_id: u.id, email_address: 'user@example.org', address_line_1: 'a', town_city: 'tc', postcode: 'pc', website_id: website.id)
          expect(u.orders.count).to eq 2
          get 'index', user_id: u.id
          expect(assigns(:orders).to_a).to eq u.orders.to_a
        end
      end
    end

    describe 'GET purge_old_unpaid' do
      it 'purges old unpaid orders' do
        Order.should_receive(:purge_old_unpaid)
        get 'purge_old_unpaid'
      end

      it 'redirects to admin orders' do
        get 'purge_old_unpaid'
        expect(response).to redirect_to(admin_orders_path)
      end
    end

    describe 'POST destroy' do
      it 'finds the order' do
        Order.should_receive(:find_by_id_and_website_id).with('1', website.id)
        post_destroy
      end

      context 'when order is found' do
        before { Order.stub(:find_by_id_and_website_id).and_return(mock_order) }

        it 'destroys the order' do
          mock_order.should_receive(:destroy)
          post_destroy
        end

        it 'redirects to admin orders' do
          post_destroy
          expect(response).to redirect_to(admin_orders_path)
        end
      end

      def post_destroy
        post 'destroy', id: '1'
      end
    end
  end
end
