require 'rails_helper'

RSpec.describe 'checkout/_upg_atlas_hidden_fields.html.slim' do
  let(:website) { FactoryGirl.build(
    :website,
    upg_atlas_check_code: 'CHECKCODE',
    upg_atlas_filename: 'payment.html',
    upg_atlas_sh_reference: 'SH12345'
  ) }
  let(:order) { FactoryGirl.build(
    :order,
    billing_full_name: 'A Shopper',
    email_address: 'shopper@example.org',
    billing_address_line_1: '123 Street',
    billing_address_line_2: 'Locality',
    billing_town_city: 'City',
    billing_county: 'County',
    billing_postcode: 'POST CODE',
    billing_country: FactoryGirl.create(:country, name: 'United Kingdom'),
    billing_phone_number: '01234 567890'
  ) }

  before do
    allow(view).to receive(:website).and_return(website)
    assign(:order, order)
    render
  end

  context 'rendered' do
    subject { rendered }
    it { should have_selector "input[type='hidden'][name='checkcode'][value='#{website.upg_atlas_check_code}']" }
    it { should have_selector "input[type='hidden'][name='filename'][value='SH12345/payment.html']" }
    it { should have_selector "input[type='hidden'][name='shreference'][value='SH12345']" }
    it { should have_selector "input[type='hidden'][name='cardholdersname'][value='#{order.billing_full_name}']" }
    it { should have_selector "input[type='hidden'][name='cardholdersemail'][value='#{order.email_address}']" }
    it { should have_selector "input[type='hidden'][name='cardholderaddr1'][value='#{order.billing_address_line_1}']" }
    it { should have_selector "input[type='hidden'][name='cardholderaddr2'][value='#{order.billing_address_line_2}']" }
    it { should have_selector "input[type='hidden'][name='cardholdercity'][value='#{order.billing_town_city}']" }
    it { should have_selector "input[type='hidden'][name='cardholderstate'][value='#{order.billing_county}']" }
    it { should have_selector "input[type='hidden'][name='cardholderpostcode'][value='#{order.billing_postcode}']" }
    it { should have_selector "input[type='hidden'][name='cardholdercountry'][value='#{order.billing_country.name}']" }
    it { should have_selector "input[type='hidden'][name='cardholdertelephonenumber'][value='#{order.billing_phone_number}']" }
  end
end
