require 'rails_helper'

RSpec.describe 'orders/index.html.slim', type: :view do
  context 'with orders' do
    let(:order) { FactoryGirl.create(:order) }

    before do
      assign(:orders, [order])
    end

    context 'when orders fully shipped' do
      before { allow(order).to receive(:fully_shipped?).and_return(true) }

      it 'links to HTML invoice' do
        render
        expect(rendered).to have_selector("a[href='#{invoice_order_path(order)}']")
      end

      it 'links to PDF invoice' do
        render
        expect(rendered).to have_selector("a[href='#{invoice_order_path(order, format: :pdf)}']")
      end
    end

    context 'when orders not fully shipped' do
      before { allow(order).to receive(:fully_shipped?).and_return(false) }
      it 'does not link to invoice' do
        render
        expect(rendered).not_to have_selector("a[href='#{invoice_order_path(order)}']")
      end
    end
  end
end
