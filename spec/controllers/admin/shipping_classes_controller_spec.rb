require 'rails_helper'

RSpec.describe Admin::ShippingClassesController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET index' do
    it 'assigns all shipping classes to @shipping_classes ordered by name' do
      sc1 = FactoryGirl.create(:shipping_class, name: 'z')
      sc2 = FactoryGirl.create(:shipping_class, name: 'a')
      get :index
      expect(assigns(:shipping_classes).first).to eq sc2
      expect(assigns(:shipping_classes).last).to eq sc1
    end
  end

  describe 'POST create' do
    let(:shipping_zone) { FactoryGirl.create(:shipping_zone) }
    let(:params) {{
      name: 'Collection',
      requires_delivery_address: false,
      shipping_zone_id: shipping_zone.id,
    }}
    before do
      post :create, shipping_class: params
    end
    it 'creates a new shipping class' do
      expect(ShippingClass.find_by(params)).to be
    end
  end
end
