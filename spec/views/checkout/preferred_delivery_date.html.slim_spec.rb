require 'rails_helper'

RSpec.describe 'checkout/preferred_delivery_date.html.slim', type: :view do
  let(:website) { FactoryBot.create(:website, preferred_delivery_date_settings: PreferredDeliveryDateSettings.new) }

  before do
    allow(view).to receive(:website).and_return(website)
  end

  it 'has a form to save preferred delivery date' do
    render
    expect(rendered).to have_selector "form[action='#{save_preferred_delivery_date_path}']"
  end

  it 'has a heading' do
    render
    expect(rendered).to have_selector 'h1', text: I18n.t('checkout.preferred_delivery_date.heading')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_selector "input[type='submit'][value='#{I18n.t('checkout.preferred_delivery_date.continue')}']"
  end
end
