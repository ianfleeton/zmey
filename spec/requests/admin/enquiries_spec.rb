require "rails_helper"

RSpec.describe "Enquiries admin", type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "GET /admin/enquiries" do
    it "lists enquiries" do
      FactoryBot.create(:enquiry, name: "Lenina Crowne")
      get "/admin/enquiries"
      expect(response.body).to include "Lenina Crowne"
    end
  end
end
