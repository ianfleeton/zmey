require 'rails_helper'

RSpec.describe 'admin/orders/index.html.slim', type: :view do
  context 'with orders' do
    let!(:order) { FactoryGirl.create(:order) }

    before do
      assign(:orders, Order.paginate({page: 1}))
    end

    it 'renders invoice links' do
      render
      expect(view).to render_template(partial: 'orders/invoice_links', locals: { order: order })
    end
  end
end
