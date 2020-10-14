require "rails_helper"

RSpec.describe Admin::ProductGroupsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "POST create" do
    let(:params) {
      {
        name: "My Product Group",
        location_id: FactoryBot.create(:location).id
      }
    }

    before do
      post :create, params: {product_group: params}
    end

    it "creates a new product group" do
      expect(ProductGroup.find_by(params)).to be
    end
  end
end
