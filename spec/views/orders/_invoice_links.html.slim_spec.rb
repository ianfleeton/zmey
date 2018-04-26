require 'rails_helper'

RSpec.describe 'orders/_invoice_links.html.slim', type: :view do
  let(:order) { FactoryBot.create(:order) }

  before do
    allow(view).to receive(:order).and_return(order)
  end

  context 'when order fully shipped' do
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

  context 'when order not fully shipped' do
    before { allow(order).to receive(:fully_shipped?).and_return(false) }
    it 'does not link to invoice' do
      render
      expect(rendered).not_to have_selector("a[href='#{invoice_order_path(order)}']")
    end
  end
end
