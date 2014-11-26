require 'rails_helper'

describe 'orders/invoice.html.slim' do
  it 'renders' do
    assign(:order, FactoryGirl.create(:order))
    allow(view).to receive(:website).and_return FactoryGirl.build(:website)

    render
  end
end
