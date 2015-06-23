require 'rails_helper'

RSpec.describe 'checkout/_select_payment_method.html.erb', type: :view do
  context 'when WorldPay active' do
    let(:website) { FactoryGirl.create(:website, worldpay_active: true, worldpay_installation_id: '1234', worldpay_payment_response_password: 'secret') }
    let(:order)   { FactoryGirl.create(:order) }

    before do
      allow(view).to receive(:website).and_return(website)
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
    let(:order)   { FactoryGirl.create(:order) }

    before do
      allow(view).to receive(:website).and_return(website)
      assign(:order, order)
    end

    it 'renders' do
      render
    end
  end

  context 'when PayPal is active' do
    let(:website) { FactoryGirl.create(:website, paypal_active: true, paypal_test_mode: test_mode) }
    let(:order)   { FactoryGirl.create(:order) }
    let(:test_mode) { false }

    before do
      allow(view).to receive(:website).and_return(website)
      assign(:order, order)
      render
    end

    it 'has a form with PayPal payment page destination' do
      expect(rendered).to have_selector "form[action='https://www.paypal.com/cgi-bin/webscr']"
    end

    it 'has a hidden notify_url field set to the IPN listener' do
      expect(rendered).to have_selector "input[type=hidden][name=notify_url][value='#{payments_paypal_ipn_listener_url}']"
    end

    context 'when in test mode (sandbox)' do
      let(:test_mode) { true }

      it 'has a form with PayPal sandbox payment page destination' do
        expect(rendered).to have_selector "form[action='https://www.sandbox.paypal.com/cgi-bin/webscr']"
      end
    end
  end

  context 'when website accepts payment on account' do
    let(:website) { FactoryGirl.create(:website, accept_payment_on_account: true) }
    let(:order)   { FactoryGirl.create(:order) }

    before do
      allow(view).to receive(:website).and_return(website)
      assign(:order, order)
    end

    it 'has a form to place order on account' do
      render
      expect(rendered).to have_selector "form[action='#{on_account_payments_path}']"
      expect(rendered).to have_selector "input[type='submit'][value='#{t("checkout.select_payment_method.place_order_on_account")}']"
    end
  end
end
