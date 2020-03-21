require "rails_helper"

RSpec.describe "Admin Liquid templates API", type: :request do
  before do
    prepare_api_website
  end

  describe "POST create" do
    it "inserts a new Liquid template into the website" do
      markup = SecureRandom.hex
      name = SecureRandom.hex
      title = SecureRandom.hex
      post "/api/admin/liquid_templates", params: {
        liquid_template: {markup: markup, name: name, title: title}
      }
      expect(LiquidTemplate.find_by(markup: markup, name: name, title: title)).to be
    end

    it "returns 422 with bad params" do
      post "/api/admin/liquid_templates", params: {liquid_template: {name: ""}}
      expect(response.status).to eq 422
    end
  end

  describe "DELETE delete_all" do
    it "deletes all Liquid templates" do
      FactoryBot.create(:liquid_template)

      delete "/api/admin/liquid_templates"

      expect(LiquidTemplate.any?).to be_falsey
    end

    it "responds with 204 No Content" do
      delete "/api/admin/liquid_templates"

      expect(status).to eq 204
    end
  end
end
