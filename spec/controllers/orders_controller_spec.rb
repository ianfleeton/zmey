require 'spec_helper'

describe OrdersController do
  let(:website) { FactoryGirl.build(:website) }
  let(:current_user) { FactoryGirl.create(:user) }

  def mock_order(stubs={})
    @mock_order ||= mock_model(Order, stubs)
  end

  before do
    controller.stub(:website).and_return(website)
  end

  describe 'GET index' do
    context 'with user' do
      before do
        controller.stub(:current_user).and_return(current_user)
      end

      it 'assigns orders belonging to the current user and website to @orders' do
        another_website = FactoryGirl.create(:website)
        expected_order = FactoryGirl.create(:order, user: current_user, website: website)
        unexpected_order_1 = FactoryGirl.create(:order, user: current_user, website: another_website)
        unexpected_order_2 = FactoryGirl.create(:order, user: FactoryGirl.create(:user), website: website)
        get 'index'
        expect(assigns(:orders)).to include(expected_order)
        expect(assigns(:orders)).not_to include(unexpected_order_1)
        expect(assigns(:orders)).not_to include(unexpected_order_2)
      end

      it 'renders index' do
        get 'index'
        expect(response).to render_template('index')
      end
    end
  end

  describe 'GET select_payment_method' do
    context 'with an order' do
      before { Order.stub(:from_session).and_return mock_order.as_null_object }

      context 'when Sage Pay is active' do
        before do
          website.stub(:sage_pay_active?).and_return(true)
          website.stub(:cardsave_active?).and_return(false)
        end

        it 'instatiates a SagePay' do
          website.stub(:sage_pay_pre_shared_key).and_return 'secret'
          mock_order.stub(:order_number).and_return '123'
          mock_order.stub(:total).and_return 15.95
          mock_order.stub(:full_name).and_return 'Ian Fleeton'
          mock_order.stub(:address_line_1).and_return '123 Street'
          mock_order.stub(:town_city).and_return 'Doncaster'
          mock_order.stub(:postcode).and_return 'DN1 2ZZ'
          mock_order.stub(:country).and_return FactoryGirl.build(:country)

          SagePay.should_receive(:new).with(hash_including(
            pre_shared_key: website.sage_pay_pre_shared_key,
            vendor_tx_code: mock_order.order_number,
            amount: mock_order.total,
            delivery_surname: mock_order.full_name,
            delivery_firstnames: mock_order.full_name,
            delivery_address: mock_order.address_line_1,
            delivery_city: mock_order.town_city,
            delivery_post_code: mock_order.postcode,
            delivery_country: mock_order.country.iso_3166_1_alpha_2,
            success_url: sage_pay_success_payments_url,
            failure_url: sage_pay_failure_payments_url
          )).and_return(double(SagePay).as_null_object)
          get :select_payment_method
        end

        it 'assigns @crypt from the SagePay' do
          SagePay.stub(:new).and_return(double(SagePay, encrypt: 'crypt'))
          get :select_payment_method
          expect(assigns(:crypt)).to eq 'crypt'
        end
      end
    end
  end

  describe 'GET invoice' do
    it 'finds the order' do
      Order.should_receive(:find_by)
      get 'invoice', id: '1'
    end

    context 'when the order is not found' do
      it 'redirects to the orders page' do
        get 'invoice', id: '1'
        expect(response).to redirect_to(orders_path)
      end
    end

    context 'when the order is found' do
      let(:order) { mock_order(user_id: 'the-owner').as_null_object }

      before do
        Order.stub(:find_by).and_return(order)
      end

      it 'requires a user' do
        get 'invoice', id: '1'
        expect(response).to redirect_to(sign_in_path)
      end

      context 'with a user' do
        before { controller.stub(:logged_in?).and_return(true) }

        context 'when the user can access the order' do
          before do
            controller.stub(:can_access_order?).and_return(true)
          end

          it 'renders the layouts/invoice template' do
            get :invoice, id: '1'
            expect(response).to render_template 'layouts/invoice'
          end
        end

        it 'redirects to sign in when the user cannot access the order' do
          controller.stub(:can_access_order?).and_return(false)
          get 'invoice', id: '1'
          expect(response).to redirect_to(new_session_path)
        end
      end
    end
  end
end
