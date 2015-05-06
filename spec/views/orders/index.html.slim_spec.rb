require 'rails_helper'

RSpec.describe 'orders/index.html.slim', type: :view do
  context 'with orders' do
    let(:order) { FactoryGirl.create(:order) }

    before do
      assign(:orders, [order])
    end

    it 'renders invoice links' do
      render
      expect(view).to render_template(partial: 'invoice_links', locals: { order: order })
    end
  end
end
