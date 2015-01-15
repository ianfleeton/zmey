require 'rails_helper'

RSpec.describe 'checkout/confirm.html.slim', type: :view do
  let(:billing_address) { FactoryGirl.create(:address) }
  let(:delivery_address) { FactoryGirl.create(:address) }

  before do
    assign(:billing_address, billing_address)
    assign(:delivery_address, delivery_address)
    assign(:basket, Basket.new)
    assign(:discount_lines, [])
    allow(view).to receive(:website).and_return(Website.new)
    allow(view).to receive(:logged_in?).and_return(false)
  end

  it 'renders' do
    render
  end
end
