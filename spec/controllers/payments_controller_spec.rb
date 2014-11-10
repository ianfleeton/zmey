require 'rails_helper'

describe PaymentsController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET index' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'uses the admin layout' do
        get :index
        expect(response).to render_template('layouts/admin')
      end
    end
  end

  describe 'GET show' do
    let(:payment) { FactoryGirl.create(:payment) }

    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'uses the admin layout' do
        get :show, id: payment.id
        expect(response).to render_template('layouts/admin')
      end
    end
  end

  describe 'POST cardsave_callback' do
    let(:params) {
      {
        Address1:            '',
        Address2:            '',
        Address3:            '',
        Address4:            '',
        Amount:              '1000',
        City:                '',
        CountryCode:         '',
        CrossReference:      '',
        CurrencyCode:        '',
        CustomerName:        '',
        Message:             '',
        OrderDescription:    '',
        OrderID:             '',
        PostCode:            '',
        PreviousMessage:     '',
        PreviousStatusCode:  '',
        State:               '',
        StatusCode:          '0',
        TransactionDateTime: '',
        TransactionType:     '',
      }
    }
    it 'creates a new payment' do
      expect{post :cardsave_callback, params}.to change{Payment.count}.by(1)
    end
  end

  describe '#rbs_worldpay_callback' do
    context 'with successful payment details' do
      let(:cartId) { 'NO SUCH CART' }
      let(:params) {
        {
          callbackPW: '',
          cartId: cartId,
          transStatus: 'Y',
        }
      }

      it 'creates a new payment' do
        expect{post :rbs_worldpay_callback, params}.to change{Payment.count}.by(1)
      end

      it 'sets a message' do
        post :rbs_worldpay_callback, params
        expect(assigns(:message)).to eq 'Payment received'
      end

      context 'with matching order' do
        let(:order)  { FactoryGirl.create(:order) }
        let(:cartId) { order.order_number }

        it 'sets the order status to payment received' do
          post :rbs_worldpay_callback, params
          expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
        end
      end
    end
  end
end
