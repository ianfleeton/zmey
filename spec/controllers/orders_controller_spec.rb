require 'rails_helper'

describe OrdersController do
  let(:website) { FactoryGirl.build(:website) }
  let(:current_user) { FactoryGirl.create(:user) }

  def mock_order(stubs={})
    @mock_order ||= double(Order, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET index' do
    context 'with user' do
      before do
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      it 'assigns orders belonging to the current user to @orders' do
        another_website = FactoryGirl.create(:website)
        expected_order = FactoryGirl.create(:order, user: current_user)
        unexpected_order = FactoryGirl.create(:order, user: FactoryGirl.create(:user))
        get 'index'
        expect(assigns(:orders)).to include(expected_order)
        expect(assigns(:orders)).not_to include(unexpected_order)
      end

      it 'renders index' do
        get 'index'
        expect(response).to render_template('index')
      end
    end
  end

  describe 'GET invoice' do
    it 'finds the order' do
      expect(Order).to receive(:find_by)
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
        allow(Order).to receive(:find_by).and_return(order)
      end

      it 'requires a user' do
        get 'invoice', id: '1'
        expect(response).to redirect_to(sign_in_path)
      end

      context 'with a user' do
        before { allow(controller).to receive(:logged_in?).and_return(true) }

        context 'when the user can access the order' do
          before do
            allow(controller).to receive(:can_access_order?).and_return(true)
          end

          context 'when the order is fully shipped' do
            before { allow(order).to receive(:fully_shipped?).and_return(true) }
            it 'renders the layouts/invoice template' do
              get :invoice, id: '1'
              expect(response).to render_template 'layouts/invoice'
            end
          end

          context 'when the order is not fully shipped' do
            before { allow(order).to receive(:fully_shipped?).and_return(false) }
            it 'redirects to the orders page' do
              get :invoice, id: '1'
              expect(response).to redirect_to(orders_path)
            end
          end
        end

        it 'redirects to sign in when the user cannot access the order' do
          allow(controller).to receive(:can_access_order?).and_return(false)
          get 'invoice', id: '1'
          expect(response).to redirect_to(new_session_path)
        end
      end
    end
  end
end
