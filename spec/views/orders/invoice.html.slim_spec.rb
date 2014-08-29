require 'rails_helper'

describe 'orders/invoice.html.slim' do
  it 'renders' do
    assign(:order, FactoryGirl.create(:order))

    render
  end
end
