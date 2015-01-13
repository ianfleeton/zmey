require 'rails_helper'

RSpec.describe 'checkout/index.html.slim' do
  it 'has a form to save details' do
    render
    expect(rendered).to have_selector "form[action='#{save_details_path}']"
  end

  it 'has fields for name, phone and email' do
    render
    expect(rendered).to have_selector 'input[name="name"]'
    expect(rendered).to have_selector 'input[name="email"][type="email"]'
    expect(rendered).to have_selector 'input[name="phone"][type="tel"]'
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_selector "input[type='submit'][value='#{I18n.t('checkout.index.continue')}']"
  end
end
