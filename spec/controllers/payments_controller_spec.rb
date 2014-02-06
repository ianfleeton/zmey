require 'spec_helper'

describe PaymentsController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
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
end
