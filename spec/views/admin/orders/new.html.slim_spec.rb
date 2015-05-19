require 'rails_helper'

RSpec.describe 'admin/orders/new.html.slim' do
  let(:order) { Order.new }
  let(:website) { FactoryGirl.create(:website) }

  before do
    assign(:order, order)
    allow(view).to receive(:website).and_return(website)
  end

  it 'renders' do
    render
  end
end
