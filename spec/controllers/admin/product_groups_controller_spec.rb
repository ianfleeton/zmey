require 'rails_helper'

RSpec.describe Admin::ProductGroupsController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    logged_in_as_admin
  end

  describe 'POST create' do
    let(:params) {{
      name: 'My Product Group',
      location: 'Warehouse B'
    }}

    before do
      post :create, product_group: params
    end

    it 'creates a new product group' do
      expect(ProductGroup.find_by(params)).to be
    end
  end
end
