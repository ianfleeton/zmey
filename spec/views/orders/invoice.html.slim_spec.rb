require 'rails_helper'

describe 'orders/invoice.html.slim' do
  it 'renders' do
    assign(:order, FactoryBot.create(:order))
    allow(view).to receive(:website).and_return FactoryBot.build(:website)

    render
  end
end
