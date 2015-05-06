require 'rails_helper'

RSpec.describe 'admin/shipments/new.html.slim' do
  let(:order) { FactoryGirl.create(:order) }

  before do
    assign(:order, order)
  end

  it 'renders a form for the @order' do
    render
    expect(rendered).to have_selector "form[action='#{admin_order_path(order)}'][method='post']"
  end

  it 'has a hidden field for the shipped_at time' do
    render
    expect(rendered).to have_selector 'input[name="order[shipped_at]"][type="hidden"]'
  end

  it 'has a text field for the shipping_tracking_number' do
    render
    expect(rendered).to have_selector 'input[name="order[shipping_tracking_number]"][type="text"]'
  end
end
