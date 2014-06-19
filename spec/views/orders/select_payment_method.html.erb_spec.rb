require 'spec_helper'

describe 'orders/select_payment_method.html.erb' do
  context 'when WorldPay active' do
    let(:website) { FactoryGirl.create(:website, worldpay_active: true, worldpay_installation_id: '1234', worldpay_payment_response_password: 'secret') }
    let(:order)   { FactoryGirl.create(:order, website: website) }

    before do
      view.stub(:website).and_return(website)
      assign(:order, order)
    end

    it 'renders' do
      render
    end

    context 'with skip_payment set' do
      before { website.skip_payment = true }

      it 'renders' do
        render
      end
    end
  end

  context 'when Cardsave active' do
    let(:website) { FactoryGirl.create(:website, cardsave_active: true) }
    let(:order)   { FactoryGirl.create(:order, website: website) }

    before do
      view.stub(:website).and_return(website)
      assign(:order, order)
    end

    it 'renders' do
      render
    end
  end
end
