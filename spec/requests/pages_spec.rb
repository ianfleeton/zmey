require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  before do
    FactoryGirl.create(:website)
  end

  describe 'GET sitemap.xml' do
    it 'includes products' do
      product = FactoryGirl.create(:product)
      get '/sitemap.xml'
      expect(response.body).to include product.url
    end
  end
end
