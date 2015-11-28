require 'rails_helper'

RSpec.describe Admin::ProductGroupPlacementsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'POST create' do
    let(:product_group) { FactoryGirl.create(:product_group) }

    before do
      post :create, product_group_placement: { product_group_id: product_group.id }
    end

    it "redirects to the placement's product group edit page" do
      expect(response).to redirect_to edit_admin_product_group_path(product_group)
    end
  end

  describe 'DELETE destroy' do
    let(:product_group_placement) { FactoryGirl.create(:product_group_placement) }

    before do
      delete :destroy, id: product_group_placement.id
    end

    it "redirects to the placement's product group edit page" do
      expect(response).to redirect_to edit_admin_product_group_path(product_group_placement.product_group)
    end
  end
end
