require 'rails_helper'

RSpec.describe 'checkout/index.html.slim', type: :view do
  before do
    assign(:address, address)
    assign(:basket, Basket.new)
    assign(:discount_lines, [])
    allow(view).to receive(:website).and_return(Website.new)
    allow(view).to receive(:logged_in?).and_return(false)
  end

  context 'with a new address' do
    let(:address) { Address.new }

    it 'renders' do
      render
    end
  end

  context 'with an existing address' do
    let(:address) { FactoryGirl.create(:address) }

    it 'renders' do
      render
    end
  end
end
