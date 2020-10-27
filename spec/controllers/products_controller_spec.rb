require "rails_helper"

RSpec.describe ProductsController, type: :controller do
  def mock_product(stubs = {})
    @mock_product ||= double(Product, stubs)
  end

  describe "GET show" do
    context "when product inactive" do
      before do
        find_requested_product(
          active?: false, page_title: "", name: "", meta_description: ""
        )
      end

      it "404s" do
        get :show, params: {slug: "widget"}
        expect(response.status).to eq 404
      end
    end
  end

  def find_requested_product(stubs = {})
    expect(Product).to receive(:find_by).with(slug: "widget").and_return(mock_product(stubs))
  end
end
