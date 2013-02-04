require 'spec_helper'

describe OrdersController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_order(stubs={})
    @mock_order ||= mock_model(Order, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'GET invoice' do
    it 'finds the order' do
      Order.should_receive(:find_by_id_and_website_id)
      get 'invoice', id: '1'
    end

    context 'when the order is not found' do
      it 'redirects to the orders page' do
        get 'invoice', id: '1'
        response.should redirect_to(orders_path)
      end
    end

    context 'when the order is found' do
      let(:order) { mock_order(user_id: 'the-owner').as_null_object }

      before do
        Order.stub(:find_by_id_and_website_id).and_return(order)
      end

      it 'requires a user' do
        get 'invoice', id: '1'
        response.should redirect_to(new_session_path)
      end

      context 'with a user' do
        before { controller.stub(:logged_in?).and_return(true) }

        context 'when the user can access the order' do
          before do
            controller.stub(:can_access_order?).and_return(true)
          end

          it 'sends the invoice file' do
            Invoice.stub(:new).and_return(mock(Invoice, filename: 'invoice.pdf').as_null_object)
            controller.should_receive(:send_file).with('invoice.pdf')
            controller.stub(:render)

            get 'invoice', id: '1'
          end
        end

        it 'redirects to sign in when the user cannot access the order' do
          controller.stub(:can_access_order?).and_return(false)
          Invoice.stub(:new).and_return(mock(Invoice).as_null_object)

          get 'invoice', id: '1'
          response.should redirect_to(new_session_path)
        end
      end
    end
  end
end
