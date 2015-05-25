require 'rails_helper'

RSpec.describe Admin::ShippingTableRowsController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET new' do
    it 'assigns @shipping_table_row with params[:shipping_class_id] set' do
      get :new, shipping_class_id: 123
      expect(assigns(:shipping_table_row).shipping_class_id).to eq 123
    end
  end

  describe 'POST create' do
    let(:shipping_class) { FactoryGirl.create(:shipping_class) }
    let(:params) {{ trigger_value: 12, amount: 34, shipping_class_id: shipping_class.id }}

    it 'creates a new shipping table row' do
      post :create, shipping_table_row: params
      expect(ShippingTableRow.find_by(params)).to be
    end
  end

  describe 'DELETE destroy' do
    let(:shipping_table_row) { FactoryGirl.create(:shipping_table_row) }
    it 'destroys the shipping table row' do
      post :destroy, id: shipping_table_row.id
      expect(ShippingTableRow.exists?(shipping_table_row.id)).to be_falsey
    end
  end
end
