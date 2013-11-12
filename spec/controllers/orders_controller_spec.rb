require 'spec_helper'

describe OrdersController do
  let(:website) { mock_model(Website).as_null_object }
  let(:current_user) { FactoryGirl.create(:user) }

  def mock_order(stubs={})
    @mock_order ||= mock_model(Order, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
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
