require "rails_helper"

RSpec.describe Admin::WebsitesController, type: :controller do
  def mock_website(stubs = {})
    @mock_website ||= double(Website, stubs)
  end

  describe "GET new" do
    context "when logged in as an administrator" do
      before { logged_in_as_admin }

      context "when no countries" do
        it "should populate countries" do
          expect(Country).to receive(:populate!)
          get :new
        end
      end
    end
  end

  describe "POST create" do
    context "when logged in as an administrator" do
      let(:valid_params) {
        {
          "country_id" => FactoryBot.create(:country).id,
          "email" => "merchant@example.com",
          "name" => "foo",
          "subdomain" => "shop"
        }
      }

      before { logged_in_as_admin }

      it "creates a new website with the given params" do
        allow(Page).to receive(:bootstrap)

        post "create", params: {website: valid_params}

        expect(Website.find_by(valid_params)).to be
      end
    end
  end
end
