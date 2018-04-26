require 'rails_helper'

feature 'Add order line' do
  let(:order) { FactoryBot.create(:order) }

  background do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Add order line happy path', js: true do
    visit edit_admin_order_path(order)

    click_button 'Add Line'
    fill_in 'order_line_quantity[-1]', with: '1'
    fill_in 'order_line_product_sku[-1]', with: 'P1'
    fill_in 'order_line_product_name[-1]', with: 'Product 1'
    fill_in 'order_line_product_weight[-1]', with: '1'
    fill_in 'order_line_product_price[-1]', with: '1'
    fill_in 'order_line_tax_percentage[-1]', with: '10'

    click_button 'Add Line'
    fill_in 'order_line_quantity[-2]', with: '2'
    fill_in 'order_line_product_sku[-2]', with: 'P2'
    fill_in 'order_line_product_name[-2]', with: 'Product 2'
    fill_in 'order_line_product_weight[-2]', with: '2'
    fill_in 'order_line_product_price[-2]', with: '2'
    fill_in 'order_line_tax_percentage[-2]', with: '20'

    click_button 'Save'

    expect(order.order_lines.count).to eq 2
  end
end
