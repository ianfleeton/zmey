require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET new' do
    let(:order) { FactoryGirl.create(:order) }

    it 'sets the shipment order_id from the order_id param' do
      get :new, order_id: order.id
      expect(assigns(:shipment).order).to eq order
    end
  end

  describe 'POST create' do
    let(:valid_params) { {
      courier_name: 'Courier',
      order_id: order.id,
      partial: [true, false].sample,
      picked_by: 'Jo Picker',
      number_of_parcels: 2,
      shipped_at: Time.zone.now,
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

    context 'when fail' do
      before do
        allow_any_instance_of(Shipment).to receive(:save).and_return(false)
      end

      it 'renders new' do
        post_create
        expect(response).to render_template 'new'
      end

      it 'assigns @shipment' do
        post_create
        expect(assigns(:shipment)).to be_instance_of(Shipment)
      end
    end

    def post_create
      post :create, shipment: valid_params
    end
  end
end
