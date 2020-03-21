require "rails_helper"

RSpec.describe "Admin product groups API", type: :request do
  before do
    prepare_api_website
  end

  describe "GET index" do
    context "with product groups" do
      before do
        @group1 = FactoryBot.create(:product_group)
        @group2 = FactoryBot.create(:product_group)
      end

      it "returns all groups" do
        get "/api/admin/product_groups"

        groups = JSON.parse(response.body)

        expect(groups["product_groups"].length).to eq 2
        expect(groups["product_groups"][0]["id"]).to eq @group1.id
        expect(groups["product_groups"][0]["href"]).to eq api_admin_product_group_url(@group1)
        expect(groups["product_groups"][1]["id"]).to eq @group2.id
        expect(groups["product_groups"][1]["href"]).to eq api_admin_product_group_url(@group2)
      end

      it "returns 200 OK" do
        get "/api/admin/product_groups"
        expect(response.status).to eq 200
      end
    end

    context "with no product groups" do
      it "returns 200 OK" do
        get "/api/admin/product_groups"
        expect(response.status).to eq 200
      end

      it "returns an empty set" do
        get "/api/admin/product_groups"
        product_groups = JSON.parse(response.body)
        expect(product_groups["product_groups"].length).to eq 0
      end
    end
  end

  describe "GET show" do
    context "when product group found" do
      let(:product_group) { FactoryBot.create(:product_group) }

      it "returns 200 OK" do
        get api_admin_product_group_path(product_group)
        expect(response.status).to eq 200
      end

      it "includes its attributes" do
        get api_admin_product_group_path(product_group)
        parsed = JSON.parse(response.body)["product_group"]
        expect(parsed["id"]).to eq product_group.id
        expect(parsed["href"]).to eq api_admin_product_group_url(product_group)
        expect(parsed["name"]).to eq product_group.name
        expect(parsed["location"]).to eq product_group.location
      end

      it "includes products" do
        product = FactoryBot.create(:product)
        product_group.products << product
        product_group.save
        get api_admin_product_group_path(product_group)
        expect(JSON.parse(response.body)["product_group"]["products"][0]["href"]).to eq api_admin_product_url(product)
      end
    end

    context "when no product group" do
      it "returns 404 Not Found" do
        get "/api/admin/product_groups/0"
        expect(response.status).to eq 404
      end
    end
  end

  describe "POST create" do
    it "inserts a new product group into the website" do
      name = SecureRandom.hex
      location = SecureRandom.hex
      post "/api/admin/product_groups", params: {product_group: {name: name, location: location}}
      expect(ProductGroup.find_by(name: name, location: location)).to be
    end

    it "returns 422 with bad params" do
      post "/api/admin/product_groups", params: {product_group: {name: ""}}
      expect(response.status).to eq 422
    end
  end

  describe "DELETE delete_all" do
    it "deletes all products groups and product group associations" do
      product = FactoryBot.create(:product)
      group = FactoryBot.create(:product_group)
      ProductGroupPlacement.create!(product: product, product_group: group)

      delete "/api/admin/product_groups"

      expect(ProductGroup.count).to eq 0
      expect(ProductGroupPlacement.count).to eq 0
    end

    it "responds with 204 No Content" do
      delete "/api/admin/product_groups"

      expect(status).to eq 204
    end
  end
end
