require 'rails_helper'

RSpec.describe Admin::ShippingZonesController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET index' do
    it 'assigns all shipping zones to @shipping_zones ordered by name' do
      sz1 = FactoryGirl.create(:shipping_zone, name: 'z')
      sz2 = FactoryGirl.create(:shipping_zone, name: 'a')
      get :index
      expect(assigns(:shipping_zones).first).to eq sz2
      expect(assigns(:shipping_zones).last).to eq sz1
    end
  end

  describe 'POST create' do
    let(:shipping_class) { FactoryGirl.create(:shipping_class) }
    let(:params) { {name: 'UK Mainland', default_shipping_class_id: shipping_class.id} }

    context 'when successful' do
      it 'creates a new ShippingZone' do
        post_create
        expect(ShippingZone.find_by(params)).to be
      end
    end

    def post_create
      post :create, shipping_zone: params
    end
  end

  describe 'DELETE destroy' do
    let(:shipping_zone) { FactoryGirl.create(:shipping_zone) }

    it 'deletes the shipping zone' do
      delete :destroy, id: shipping_zone.id
      expect(ShippingZone.find_by(id: shipping_zone.id)).to be_nil
    end
  end
end
