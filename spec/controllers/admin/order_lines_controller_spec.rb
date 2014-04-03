require 'spec_helper'

describe Admin::OrderLinesController do
  before { logged_in_as_admin }

  describe 'PATCH update' do
    it 'updates an order line' do
      ol = FactoryGirl.create(:order_line)
      new_quantity = rand(100)
      patch :update, id: ol.id, order_line: {
        quantity: new_quantity
      }
      expect(OrderLine.find(ol.id).quantity).to eq new_quantity
    end

    it 'redirects to the admin show order page' do
      ol = FactoryGirl.create(:order_line)
      patch :update, id: ol.id, order_line: ol.attributes
      expect(response).to redirect_to admin_order_path(ol.order)
    end
  end
end
