require 'rails_helper'

describe 'Admin Liquid templates API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    it 'inserts a new Liquid template into the website' do
      markup = SecureRandom.hex
      name   = SecureRandom.hex
      title  = SecureRandom.hex
      post '/api/admin/liquid_templates', liquid_template: {markup: markup, name: name, title: title}
      expect(LiquidTemplate.find_by(markup: markup, name: name, title: title, website_id: @website.id)).to be
    end

    it 'returns 422 with bad params' do
      post '/api/admin/liquid_templates', liquid_template: {name: ''}
      expect(response.status).to eq 422
    end
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
