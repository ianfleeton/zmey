require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  before do
    FactoryBot.create(:website)
  end

  describe 'GET sitemap.xml' do
    it 'includes products' do
      product = FactoryBot.create(:product)
      get '/sitemap.xml'
      expect(response.body).to include product.url
    end
  end
end
