require "rails_helper"

RSpec.describe Admin::ShippingZonesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "POST create" do
    let(:shipping_class) { FactoryBot.create(:shipping_class) }
    let(:params) { {name: "UK Mainland", default_shipping_class_id: shipping_class.id} }

    context "when successful" do
      it "creates a new ShippingZone" do
        post_create
        expect(ShippingZone.find_by(params)).to be
      end
    end

    def post_create
      post :create, params: {shipping_zone: params}
    end
  end

  describe "DELETE destroy" do
    let(:shipping_zone) { FactoryBot.create(:shipping_zone) }

    it "deletes the shipping zone" do
      delete :destroy, params: {id: shipping_zone.id}
      expect(ShippingZone.find_by(id: shipping_zone.id)).to be_nil
    end
  end
end
