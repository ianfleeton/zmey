require 'rails_helper'

RSpec.describe Admin::ShippingTableRowsController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'POST create' do
    let(:shipping_class) { FactoryBot.create(:shipping_class) }
    let(:params) {{ trigger_value: 12, amount: 34, shipping_class_id: shipping_class.id }}

    it 'creates a new shipping table row' do
      post :create, params: { shipping_table_row: params }
      expect(ShippingTableRow.find_by(params)).to be
    end
  end

  describe 'DELETE destroy' do
    let(:shipping_table_row) { FactoryBot.create(:shipping_table_row) }
    it 'destroys the shipping table row' do
      post :destroy, params: { id: shipping_table_row.id }
      expect(ShippingTableRow.exists?(shipping_table_row.id)).to be_falsey
    end
  end
end
