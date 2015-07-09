require 'rails_helper'

RSpec.describe 'Admin shipments API', type: :request do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order) }

    let(:order_id)    { order.id }

    # Attributes
    let(:courier_name) { nil }
    let(:number_of_parcels) { 2 }
    let(:picked_by) { 'Jo Picker' }
    let(:shipped_at) { Time.zone.now }
    let(:total_weight) { 1 }
    let(:tracking_number) { '123' }
    let(:tracking_url) { 'http://trackyourorder.url/123' }

    before do
      post '/api/admin/shipments', shipment: {
        courier_name: courier_name,
        order_id: order_id,
        partial: [true, false].sample,
        picked_by: picked_by,
        total_weight: total_weight,
        tracking_number: tracking_number,
        tracking_url: tracking_url,
      }
    end

    context 'with invalid order' do
      let(:order_id) { order.id + 1 }

      it 'responds 422' do
        expect(response.status).to eq 422
      end

      it 'includes an error message in JSON' do
        expect(JSON.parse(response.body)).to eq ['Order does not exist.']
      end
    end

    context 'with valid attributes' do
      let(:shipment) { order.reload.shipments.first }

      it 'creates a shipment with supplied attributes' do
        expect(shipment).to be
        expect(shipment.order_id).to eq order_id
        expect(shipment.picked_by).to eq picked_by
        expect(shipment.tracking_number).to eq tracking_number
        expect(shipment.tracking_url).to eq tracking_url
      end

      it 'responds 200' do
        expect(response.status).to eq 200
      end

      context 'JSON response' do
        subject { JSON.parse(response.body) }

        it 'includes the id and href of the newly created resource' do
          expect(subject['shipment']['id']).to eq shipment.id
          expect(subject['shipment']['href']).to eq api_admin_shipment_url(shipment)
        end
      end
    end
  end
end