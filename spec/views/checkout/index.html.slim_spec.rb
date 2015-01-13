require 'rails_helper'

RSpec.describe 'checkout/index.html.slim', type: :view do
  before do
    assign(:address, Address.new)
    assign(:basket, Basket.new)
    assign(:discount_lines, [])
    allow(view).to receive(:website).and_return(Website.new)
  end

  it 'renders' do
    render
  end
end
