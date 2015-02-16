require 'rails_helper'

RSpec.describe 'checkout/confirm.html.slim', type: :view do
  let(:billing_address) { FactoryGirl.create(:address) }
  let(:delivery_address) { FactoryGirl.create(:address) }
  let(:name) { SecureRandom.hex }
  let(:email) { SecureRandom.hex }
  let(:phone) { SecureRandom.hex }

  before do
    assign(:billing_address, billing_address)
    assign(:delivery_address, delivery_address)
    assign(:basket, Basket.new)
    assign(:discount_lines, [])
    allow(view).to receive(:website).and_return(Website.new)
    allow(view).to receive(:logged_in?).and_return(false)    
    session[:name] = name
    session[:email] = email
    session[:phone] = phone
  end

  it 'shows customer details' do
    render
    expect(rendered).to have_content I18n.t('checkout.confirm.your_details')
    expect(rendered).to have_content name
    expect(rendered).to have_content email
    expect(rendered).to have_content phone
  end

  it 'has a link to edit details' do
    render
    expect(rendered).to have_selector "a[href='#{checkout_details_path}']", text: I18n.t('checkout.confirm.edit_details')
  end

  it 'shows billing address' do
    render
    expect(rendered).to have_content I18n.t('checkout.confirm.billing_address')
  end

  it 'links to edit billing address' do
    render
    expect(rendered).to have_selector "a[href='#{billing_details_path}']", text: I18n.t('checkout.confirm.edit_address')
  end

  it 'shows delivery address' do
    render
    expect(rendered).to have_content I18n.t('checkout.confirm.delivery_address')
  end

  it 'links to edit delivery address' do
    render
    expect(rendered).to have_selector "a[href='#{delivery_details_path}']", text: I18n.t('checkout.confirm.edit_address')
  end
end
