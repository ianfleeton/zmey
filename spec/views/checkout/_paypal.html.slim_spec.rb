require 'rails_helper'

RSpec.describe 'checkout/_paypal.html.slim', type: :view do
  let(:website) { FactoryGirl.create(:website, paypal_active: true, paypal_test_mode: test_mode, paypal_email_address: 'paypal@example.com') }
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

  context 'rendered' do
    subject { rendered }
    it { should have_selector "input[type=hidden][name=business][value='#{website.paypal_email_address}']"}
    it { should have_selector "input[type=hidden][name=item_name][value='#{order.order_number}']"}
    it { should have_selector "input[type=hidden][name=amount][value='#{order.total}']"}
  end

  context 'when in test mode (sandbox)' do
    let(:test_mode) { true }

    it 'has a form with PayPal sandbox payment page destination' do
      expect(rendered).to have_selector "form[action='https://www.sandbox.paypal.com/cgi-bin/webscr']"
    end
  end
end
