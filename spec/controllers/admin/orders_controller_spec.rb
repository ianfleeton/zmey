require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::OrdersController do
  let(:website) { FactoryGirl.create(:website) }

  def mock_order(stubs={})
    @mock_order ||= double(Order, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  context 'when admin or manager' do
    before { allow(controller).to receive(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      context 'with no user supplied' do
        pending
      end

      context 'with user supplied' do
        it 'assigns all orders for the supplied user to @orders' do
          u = User.create!(email: 'user@example.org', name: 'Alice', password: 'secret')
          country = FactoryGirl.create(:country)
          FactoryGirl.create(:order, user_id: u.id)
          FactoryGirl.create(:order, user_id: u.id, created_at: Date.today - 1.day)
          expect(u.orders.count).to eq 2
          get 'index', user_id: u.id
          expect(assigns(:orders).to_a).to eq u.orders.to_a
        end
      end
    end

    describe 'GET new' do
      it 'assigns a new Order to @order' do
        get :new
        expect(assigns(:order)).to be_instance_of(Order)
        expect(assigns(:order).new_record?).to be_truthy
      end
    end

    describe 'POST create' do
      let(:email) { SecureRandom.hex }
      let(:order) { FactoryGirl.build(:order, email_address: email) }

      it 'creates an order' do
        post :create, order: order.attributes
        expect(Order.find_by(email_address: email)).to be
      end

      it 'sets the order status to WAITING_FOR_PAYMENT' do
        post :create, order: order.attributes
        expect(Order.last.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end

      context 'when save succeeds' do
        before do
          allow_any_instance_of(Order).to receive(:save).and_return(true)
        end

        it 'redirects to the admin orders page' do
          post :create, order: order.attributes
          expect(response).to redirect_to admin_orders_path
        end
      end

      context 'when save succeeds' do
        before do
          allow_any_instance_of(Order).to receive(:save).and_return(false)
        end

        it 'renders new' do
          post :create, order: order.attributes
          expect(response).to render_template 'new'
        end
      end
    end

    describe 'GET edit' do
      let(:order) { FactoryGirl.create(:order) }

      it 'assigns the order to @order' do
        get :edit, id: order.id
        expect(assigns(:order)).to eq order
      end
    end

    describe 'PATCH update' do
      let(:order) { FactoryGirl.create(:order) }

      it 'assigns the order to @order' do
        patch :update, id: order.id
        expect(assigns(:order)).to eq order
      end      

      it 'redirects to the edit order page' do
        patch :update, id: order.id
        expect(response).to redirect_to edit_admin_order_path(order)
      end
    end

    describe 'GET purge_old_unpaid' do
      it 'purges old unpaid orders' do
        expect(Order).to receive(:purge_old_unpaid)
        get 'purge_old_unpaid'
      end

      it 'redirects to admin orders' do
        get 'purge_old_unpaid'
        expect(response).to redirect_to(admin_orders_path)
      end
    end

    describe 'POST destroy' do
      it 'finds the order' do
        expect(Order).to receive(:find_by).with(id: '1')
        post_destroy
      end

      context 'when order is found' do
        before { allow(Order).to receive(:find_by).and_return(mock_order) }

        it 'destroys the order' do
          expect(mock_order).to receive(:destroy)
          post_destroy
        end

        it 'redirects to admin orders' do
          allow(mock_order).to receive(:destroy)
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
