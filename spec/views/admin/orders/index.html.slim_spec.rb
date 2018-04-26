require 'rails_helper'

RSpec.describe 'admin/orders/index.html.slim', type: :view do
  context 'with orders' do
    let!(:order) { FactoryBot.create(:order, billing_full_name: 'BILLING FN') }

    before do
      assign(:orders, Order.paginate({page: 1}))
    end

    it 'displays the billing full name' do
      render
      expect(rendered).to have_content 'BILLING FN'
    end

    context 'when sales conversion should be recorded, but has not  yet been' do
      before do
        allow_any_instance_of(Order).to receive(:should_record_sales_conversion?).and_return(true)
      end
      it 'links to record sales conversion in a new tab/window' do
        render
        expect(rendered).to have_selector "a[href='#{record_sales_conversion_admin_order_path(order)}'][target='_blank']"
      end
    end
  end
end
