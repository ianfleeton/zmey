require 'rails_helper'

RSpec.describe Admin::OrderLinesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'PATCH update' do
    it 'updates an order line' do
      ol = FactoryGirl.create(:order_line)
      new_quantity = rand(100) + 1
      patch :update, params: {
        id: ol.id, order_line: {
          quantity: new_quantity
        }
      }
      expect(OrderLine.find(ol.id).quantity).to eq new_quantity
    end

    it 'redirects to the admin show order page' do
      ol = FactoryGirl.create(:order_line)
      patch :update, params: { id: ol.id, order_line: ol.attributes }
      expect(response).to redirect_to admin_order_path(ol.order)
    end
  end

  describe 'DELETE destroy' do
    let(:order_line) { FactoryGirl.create(:order_line) }

    before { delete :destroy, params: { id: order_line.id } }

    it 'deletes to order line' do
      expect(OrderLine.find_by(id: order_line.id)).to be_nil
    end

    it 'redirects to edit order' do
      expect(response).to redirect_to edit_admin_order_path(order_line.order)
    end
  end
end
