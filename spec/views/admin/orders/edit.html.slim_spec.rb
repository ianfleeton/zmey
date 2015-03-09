require 'rails_helper'

RSpec.describe 'admin/orders/edit.html.slim', type: :view do
  let(:order) { FactoryGirl.create(:order) }

  before do
    assign(:order, order)
  end

  context 'with payments' do
    before do
      FactoryGirl.create(:payment, order: order)
    end

    it 'renders payments' do
      render
      expect(view).to render_template '_payments'
    end
  end
end
