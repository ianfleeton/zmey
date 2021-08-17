require "rails_helper"

RSpec.describe "Websites admin", type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "GET /admin/websites/new" do
    context "when no countries" do
      it "should populate countries" do
        expect(Country).to receive(:populate!)
        get "/admin/websites/new"
      end
    end
  end

  describe "POST /admin/websites" do
    before do
      post "/admin/websites", params: {website: params}
    end

    context "with valid params" do
      let(:params) {
        {
          "country_id" => FactoryBot.create(:country).id,
          "email" => "merchant@example.com",
          "name" => "foo",
          "subdomain" => "shop"
        }
      }

      it "creates a new website with the given params" do
        expect(Website.find_by(params)).to be
      end
    end

    context "with invalid params" do
      let(:params) {
        {
          "country_id" => FactoryBot.create(:country).id,
          "email" => "",
          "name" => "",
          "subdomain" => "shop"
        }
      }

      it "re-renders the form with error messages" do
        expect(response.body).to include("errors prohibited this website from being saved")
      end
    end
  end
end
