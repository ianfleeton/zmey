require "rails_helper"

RSpec.describe Admin::ProductPlacementsController, type: :controller do
  describe "POST create" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "redirects to the page edit page" do
        page = double(Page)
        pp = double(ProductPlacement, page: page, save: true)
        allow(ProductPlacement).to receive(:new).and_return(pp)
        post "create", params: {"product_placement" => {"some" => "params"}}
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end

  describe "DELETE destroy" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "redirects to the page edit page" do
        page = double(Page)
        pp = double(ProductPlacement, page: page, destroy: nil)
        allow(ProductPlacement).to receive(:find).and_return(pp)
        delete "destroy", params: {id: "1"}
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end

  describe "POST move_up" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "redirects to the page edit page" do
        page = double(Page)
        pp = double(ProductPlacement, page: page, move_higher: true)
        allow(ProductPlacement).to receive(:find).and_return(pp)
        post "move_up", params: {id: "1"}
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end
end
