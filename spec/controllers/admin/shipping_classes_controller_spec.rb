require "rails_helper"

RSpec.describe Admin::ShippingClassesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "POST create" do
    let(:shipping_zone) { FactoryBot.create(:shipping_zone) }
    let(:params) {
      {
        name: "Collection",
        requires_delivery_address: false,
        shipping_zone_id: shipping_zone.id
      }
    }
    before do
      post :create, params: {shipping_class: params}
    end
    it "creates a new shipping class" do
      expect(ShippingClass.find_by(params)).to be
    end
  end
end
