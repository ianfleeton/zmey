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

  context 'without comments' do
    it 'states no comments have been added yet' do
      render
      expect(rendered).to have_content t('admin.orders.edit.no_comments')
    end
  end

  context 'with comments' do
    before do
      FactoryGirl.create(:order_comment, order: order, comment: 'Refund requested')
    end

    it 'lists comments' do
      render
      expect(rendered).to have_content 'Refund requested'
    end
  end
end
