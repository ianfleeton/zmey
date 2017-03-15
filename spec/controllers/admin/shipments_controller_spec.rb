require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'POST create' do
    let(:valid_params) { {
      courier_name: 'Courier',
      order_id: order.id,
      partial: [true, false].sample,
      picked_by: 'Jo Picker',
      number_of_parcels: 2,
      shipped_at: '2017-03-15 20:56:17 UTC',
      total_weight: 1.234,
      tracking_number: '123',
      tracking_url: 'http://trackyourorder.url/123',
    } }
    let(:order) { FactoryGirl.create(:order) }

    context 'when successful' do
      it 'creates a new Shipment' do
        post_create
        expect(Shipment.find_by(valid_params)).to be
      end

      it 'redirects to edit order' do
        post_create
        expect(response).to redirect_to edit_admin_order_path(order)
      end
    end

    def post_create
      post :create, params: { shipment: valid_params }
    end
  end
end
