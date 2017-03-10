require 'rails_helper'

RSpec.describe Admin::ShippingClassesController, type: :controller do
  before do
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'POST create' do
    let(:shipping_zone) { FactoryGirl.create(:shipping_zone) }
    let(:params) {{
      name: 'Collection',
      requires_delivery_address: false,
      shipping_zone_id: shipping_zone.id,
    }}
    before do
      post :create, params: { shipping_class: params }
    end
    it 'creates a new shipping class' do
      expect(ShippingClass.find_by(params)).to be
    end
  end
end
