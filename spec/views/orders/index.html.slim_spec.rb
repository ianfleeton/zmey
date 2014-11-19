require 'rails_helper'

describe 'orders/index.html.slim' do
  context 'with orders' do
    before do
      assign(:orders, [FactoryGirl.create(:order)])
    end

    it 'renders' do
      render
    end
  end
end
