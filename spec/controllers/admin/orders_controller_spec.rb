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
        it 'assigns all orders, most recent first' do
          order_1 = FactoryGirl.create(:order, created_at: Date.today - 1.day)
          order_2 = FactoryGirl.create(:order)
          get :index
          expect(assigns(:orders).to_a.first).to eq(order_2)
          expect(assigns(:orders).to_a.last).to eq(order_1)
        end
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

      [:billing_company, :billing_full_name, :billing_postcode, :delivery_postcode, :email_address].each do |key|
        context "with #{key} supplied" do
          it "finds all orders with partially matching #{key}" do
            o1 = FactoryGirl.create(:order, key => 'Ian')
            o2 = FactoryGirl.create(:order, key => 'Brian')
            o3 = FactoryGirl.create(:order, key => 'Alice')
            get :index, key => 'ian'
            expect(assigns(:orders)).to include(o1)
            expect(assigns(:orders)).to include(o2)
            expect(assigns(:orders)).not_to include(o3)
          end
        end
      end

      context 'with order_number supplied' do
        it 'finds order with matching order_number' do
          o1 = FactoryGirl.create(:order, order_number: 'ORDER-1')
          o2 = FactoryGirl.create(:order, order_number: 'ORDER-2')
          get :index, order_number: 'ORDER-1'
          expect(assigns(:orders)).to include(o1)
          expect(assigns(:orders)).not_to include(o2)
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
      let(:params) {{
        billing_company: 'Billing Company',
        billing_full_name: 'A Buyer',
        billing_phone_number: '01234 567890',
        delivery_company: 'Delivery Company',
        delivery_full_name: 'A Recipient',
        delivery_phone_number: '01234 567890',
        email_address: 'shopper@example.org',
      }}
      let(:order) { FactoryGirl.build(:order, params) }

      it 'creates an order' do
        post :create, order: order.attributes
        expect(Order.find_by(params)).to be
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
      let(:po_number) { 'PO123' }
      let(:shipped_at) { Time.zone.now }
      let(:shipping_tracking_number) { 'TRACK123' }
      let(:order_params) {{
        order_number: order.order_number,
        po_number: po_number,
        shipped_at: shipped_at,
        shipping_tracking_number: shipping_tracking_number
      }}
      let(:pre) { nil }

      let(:order_line_product_name) { nil }
      let(:order_line_product_price) { nil }
      let(:order_line_product_sku) { nil }
      let(:order_line_product_weight) { nil }
      let(:order_line_quantity) { nil }
      let(:order_line_tax_percentage) { nil }

      before do
        pre.try(:call)
        patch :update, id: order.id, order: order_params,
          order_line_product_name: order_line_product_name,
          order_line_product_price: order_line_product_price,
          order_line_product_sku: order_line_product_sku,
          order_line_product_weight: order_line_product_weight,
          order_line_quantity: order_line_quantity,
          order_line_tax_percentage: order_line_tax_percentage
      end

      it 'assigns the order to @order' do
        expect(assigns(:order)).to eq order
      end

      it 'redirects to the edit order page' do
        expect(response).to redirect_to edit_admin_order_path(order)
      end

      it 'updates order details' do
        order.reload
        expect(order.po_number).to eq po_number
        expect(order.shipped_at).to be_within(1.second).of(shipped_at)
        expect(order.shipping_tracking_number).to eq shipping_tracking_number
      end

      def lock_order
        allow_any_instance_of(Order).to receive(:locked?).and_return(true)
      end

      context 'when order locked' do
        let(:pre) { -> { lock_order } }

        it 'does not update many order details' do
          expect(order.reload.po_number).to be_nil
        end

        it 'does update some details' do
          order.reload
          expect(order.shipped_at).to be_within(1.second).of(shipped_at)
          expect(order.shipping_tracking_number).to eq shipping_tracking_number
        end
      end

      context 'with new order lines' do
        let(:sku) { 'SKU' }
        let(:order_line_product_name)   { {'-1' => 'A',  '-2' => 'B'} }
        let(:order_line_product_price)  { {'-1' => '3',  '-2' => '7'} }
        let(:order_line_product_sku)    { {'-1' => sku,  '-2' => 'Z'} }
        let(:order_line_product_weight) { {'-1' => '1',  '-2' => '3'} }
        let(:order_line_quantity)       { {'-1' => '1',  '-2' => '2'} }
        let(:order_line_tax_percentage) { {'-1' => '15', '-2' => '20'} }

        it 'adds new order lines' do
          expect(order.reload.order_lines.count).to eq 2
        end

        it 'records SKUs' do
          expect(order.reload.order_lines.first.product_sku).to eq sku
        end

        context 'when order locked' do
          let(:pre) { -> { lock_order } }
          it 'does not add new lines' do
            expect(order.reload.order_lines.count).to eq 0
          end
        end
      end

      context 'with existing order lines' do
        let(:sku) { 'SKU' }
        let(:order_line) { FactoryGirl.create(:order_line, order: order, product_weight: 1, quantity: 1) }
        let(:order_line_product_name)   { { order_line.id => 'New name' } }
        let(:order_line_product_price)  { { order_line.id => 3.21 } }
        let(:order_line_product_sku)    { { order_line.id => sku } }
        let(:order_line_product_weight) { { order_line.id => 2 } }
        let(:order_line_quantity)       { { order_line.id => 3 } }
        let(:order_line_tax_percentage) { { order_line.id => 20 } }

        it 'updates the order line' do
          order_line.reload
          expect(order_line.product_name).to eq 'New name'
          expect(order_line.product_price).to eq 3.21
          expect(order_line.product_weight).to eq 2
          expect(order_line.quantity).to eq 3
        end

        it 'updates SKUs' do
          order_line.reload
          expect(order_line.product_sku).to eq sku
        end

        context 'when order locked' do
          let(:pre) { -> { lock_order } }
          it 'does not update the order line' do
            order_line.reload
            expect(order_line.product_name).not_to eq 'New name'
          end
        end
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

    describe 'GET record_sales_conversion' do
      let(:order) { FactoryGirl.create(:order) }

      it 'assigns the order to @order' do
        get :record_sales_conversion, id: order.id
        expect(assigns(:order)).to eq order
      end
    end
  end
end
