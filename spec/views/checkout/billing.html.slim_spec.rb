require 'rails_helper'

RSpec.describe 'checkout/billing.html.slim', type: :view do
  let(:address) { Address.new }

  before do
    assign(:address, address)
    render
  end

  it 'has a form to save details' do
    expect(rendered).to have_selector "form[action='#{addresses_path}'][method='post']"
  end

  [
    'address_line_1', 'address_line_2', 'town_city', 'county', 'postcode'
  ].each do |component|
    it "has a field for #{component}" do
      expect(rendered).to have_selector "input[name='address[#{component}]']"
    end
  end

  it 'has a select box for country' do
    expect(rendered).to have_selector "select[name='address[country_id]']"
  end

  it 'has a submit button' do
    expect(rendered).to have_selector "input[type='submit']"
  end
end
