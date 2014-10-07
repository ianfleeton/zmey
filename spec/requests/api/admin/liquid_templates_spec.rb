require 'rails_helper'

describe 'Admin Liquid templates API' do
  before do
    prepare_api_website
  end

  describe 'DELETE delete_all' do
    it 'deletes all Liquid templates in the website' do
      template_1 = FactoryGirl.create(:liquid_template, website_id: @website.id)
      template_2 = FactoryGirl.create(:liquid_template, website_id: FactoryGirl.create(:website).id)

      delete '/api/admin/liquid_templates'

      expect(LiquidTemplate.find_by(id: template_1.id)).not_to be
      expect(LiquidTemplate.find_by(id: template_2.id)).to be
    end

    it 'responds with 204 No Content' do
      delete '/api/admin/liquid_templates'

      expect(status).to eq 204
    end
  end
end
