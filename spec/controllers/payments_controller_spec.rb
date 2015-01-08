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

  CALLBACK_PARAMS = {
    Address1:            'a1',
    Address2:            'a2',
    Address3:            'a3',
    Address4:            'a4',
    Amount:              '1000',
    City:                'ct',
    CountryCode:         '123',
    CrossReference:      'xr',
    CurrencyCode:        '456',
    CustomerName:        'cn',
    Message:             'msg',
    OrderDescription:    'od',
    OrderID:             'id',
    PostCode:            'pc',
    PreviousMessage:     'pm',
    PreviousStatusCode:  'psc',
    State:               'st',
    StatusCode:          '0',
    TransactionDateTime: 'sc',
    TransactionType:     'tt',
  }

  describe 'POST cardsave_callback' do
    let(:params) { CALLBACK_PARAMS }

    it 'creates a new payment' do
      expect{post :cardsave_callback, params}.to change{Payment.count}.by(1)
    end
  end

  describe '#cardsave_plaintext_post' do
    let(:params) { CALLBACK_PARAMS }

    before do
      website.cardsave_pre_shared_key = 'xyzzy'
      website.cardsave_merchant_id = 'plugh'
      website.cardsave_password = 'plover'

      post :cardsave_callback, params
    end

    it 'interpolates cardsave settings and callback params in order' do
      expect(controller.send(:cardsave_plaintext_post)).to eq "PreSharedKey=xyzzy&MerchantID=plugh&Password=plover&StatusCode=0&Message=msg&PreviousStatusCode=psc&PreviousMessage=pm&CrossReference=xr&Amount=1000&CurrencyCode=456&OrderID=id&TransactionType=tt&TransactionDateTime=sc&OrderDescription=od&CustomerName=cn&Address1=a1&Address2=a2&Address3=a3&Address4=a4&City=ct&State=st&PostCode=pc&CountryCode=123"
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
