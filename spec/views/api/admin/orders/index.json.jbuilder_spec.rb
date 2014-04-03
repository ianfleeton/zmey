require 'spec_helper'

describe 'api/admin/orders/index.json.jbuilder' do
  let(:order) { FactoryGirl.create(:order) }

  it 'includes details about the order' do
    assign(:orders, [order])
    render
    expect(rendered).to match(order.order_number)
  end

  it 'includes order lines' do
    sku = 'MYSKU'
    order.order_lines << FactoryGirl.build(:order_line, product_sku: sku)
    assign(:orders, [order])
    render
    expect(rendered).to match(sku)
  end
end
