require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }

  def mock_order(stubs={})
    @mock_order ||= double(Order, stubs)
  end

  describe 'GET invoice' do
    it 'finds the order' do
      expect(Order).to receive(:find_by)
      get 'invoice', params: { id: '1' }
    end

    context 'when the order is not found' do
      it 'redirects to the orders page' do
        get 'invoice', params: { id: '1' }
        expect(response).to redirect_to(orders_path)
      end
    end

    context 'when the order is found' do
      let(:order) { mock_order(user_id: 'the-owner').as_null_object }

      before do
        allow(Order).to receive(:find_by).and_return(order)
      end

      it 'requires a user' do
        get 'invoice', params: { id: '1' }
        expect(response).to redirect_to(sign_in_path)
      end

      context 'with a user' do
        before { allow(controller).to receive(:logged_in?).and_return(true) }

        context 'when the user can access the order' do
          before do
            allow(controller).to receive(:can_access_order?).and_return(true)
          end

          context 'when the order is not fully shipped' do
            before { allow(order).to receive(:fully_shipped?).and_return(false) }
            it 'redirects to the orders page' do
              get :invoice, params: { id: '1' }
              expect(response).to redirect_to(orders_path)
            end
          end
        end

        it 'redirects to sign in when the user cannot access the order' do
          allow(controller).to receive(:can_access_order?).and_return(false)
          get 'invoice', params: { id: '1' }
          expect(response).to redirect_to(new_session_path)
        end
      end
    end

    context 'format is pdf' do
      let(:order) { FactoryBot.create(:order) }
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:can_access_order?).and_return(true)
        allow_any_instance_of(Order).to receive(:fully_shipped?).and_return(true)
      end

      it 'generates and sends an invoice PDF' do
        invoice = double(PDF::Invoice)
        expect(PDF::Invoice).to receive(:new).and_return(invoice)
        expect(invoice).to receive(:generate)
        expect(invoice).to receive(:filename).and_return File.join(['spec', 'fixtures', 'pdf', 'fake.pdf'])
        get :invoice, params: { id: order.id, format: :pdf }
      end
    end
  end
end
