require 'rails_helper'

describe 'Admin features API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    let(:product) { FactoryGirl.create(:product) }
    let(:params) {{
      feature: {
        name: SecureRandom.hex,
        product_id: product.id
      }
    }}

    it 'adds a new feature to a product' do
      post '/api/admin/features', params: params
      expect(Feature.find_by(name: params[:feature][:name], product_id: product.id)).to be
    end

    it 'sets the feature type to text field' do
      post '/api/admin/features', params: params
      expect(Feature.last.ui_type).to eq Feature::TEXT_FIELD
    end

    it 'returns 422 with bad params' do
      post '/api/admin/features', params: { feature: { name: '' } }
      expect(response.status).to eq 422
    end
  end
end
