# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Couriers admin", type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "GET /admin/couriers" do
    it "lists all couriers in alphabet order" do
      FactoryBot.create(:courier, name: "Yodel")
      FactoryBot.create(:courier, name: "DX")
      get "/admin/couriers"
      assert_select "tr td", text: "DX"
      assert_select "tr + tr td", text: "Yodel"
    end
  end

  describe "GET /admin/couriers/new" do
    it "renders a form for a new courier" do
      get "/admin/couriers/new"
      assert_select "form[action='#{admin_couriers_path}']" do
        assert_select "input[name='courier[consignment_prefix]']"
      end
    end
  end

  describe "POST /admin/couriers" do
    before { post "/admin/couriers", params: {courier: params} }

    context "with valid params" do
      let(:courier) { FactoryBot.create(:courier) }
      let(:params) { {consignment_prefix: "PREFIX", name: "C"} }

      it "creates a new courier" do
        expect(Courier.count).to eq 1
        courier = Courier.first
        expect(courier.consignment_prefix).to eq "PREFIX"
        expect(courier.name).to eq "C"
      end

      it "redirects to couriers index" do
        expect(response).to redirect_to admin_couriers_path
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq "Saved."
      end
    end

    context "with invalid params" do
      let(:params) { {name: nil, account_number: "123"} }

      it "re-renders the new courier form" do
        assert_select "form[action='#{admin_couriers_path}']"
        assert_select "input[name='courier[account_number]'][value='123']"
      end
    end
  end

  describe "GET /admin/couriers/:id/edit" do
    it "renders a form to edit the courier" do
      c = FactoryBot.create(:courier)
      get "/admin/couriers/#{c.id}/edit"
      assert_select "form[action='#{admin_courier_path(c)}']"
    end
  end

  describe "PATCH /admin/couriers/:id" do
    let(:c) { FactoryBot.create(:courier) }
    before { patch "/admin/couriers/#{c.id}", params: {courier: params} }

    context "with valid params" do
      let(:courier) { FactoryBot.create(:courier) }
      let(:params) { {name: "NEWNAME"} }

      it "updates the courier" do
        updated = Courier.last
        expect(updated.name).to eq "NEWNAME"
      end

      it "redirects to couriers index" do
        expect(response).to redirect_to admin_couriers_path
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq "Saved."
      end
    end

    context "with invalid params" do
      let(:params) { {name: nil, account_number: "123"} }

      it "re-renders the edit courier form" do
        assert_select "form[action='#{admin_courier_path(c)}']"
        assert_select "input[name='courier[account_number]'][value='123']"
      end
    end
  end

  describe "DELETE /admin/couriers/:id" do
    let(:c) { FactoryBot.create(:courier) }
    before { delete "/admin/couriers/#{c.id}" }

    it "destroys the courier" do
      expect(Courier.find_by(id: c.id)).to be_nil
    end

    it "redirects to couriers index" do
      expect(response).to redirect_to admin_couriers_path
    end

    it "sets a flash notice" do
      expect(flash[:notice]).to eq "Deleted."
    end
  end
end
