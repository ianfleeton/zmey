require "rails_helper"

module Admin
  RSpec.describe ShipmentsController, type: :controller do
    before do
      logged_in_as_admin
    end

    describe "POST create" do
      let(:courier) { FactoryBot.create(:courier) }
      let(:order) { FactoryBot.create(:order) }
      let(:valid_params) {
        {
          courier_id: courier.id,
          order_id: order.id,
          partial: [true, false].sample,
          picked_by: "Jo Picker",
          number_of_parcels: 2,
          shipped_at: "2017-03-15 20:56:17 UTC",
          total_weight: 1.234,
          consignment_number: "123",
          tracking_url: "http://trackyourorder.url/123"
        }
      }

      context "when successful" do
        it "creates a new Shipment" do
          post_create
          expect(Shipment.find_by(valid_params)).to be
        end

        it "redirects to edit order" do
          post_create
          expect(response).to redirect_to edit_admin_order_path(order)
        end
      end

      def post_create
        post :create, params: {shipment: valid_params}
      end
    end
  end
end
