require 'rails_helper'

RSpec.describe Admin::ProductGroupsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'GET index' do
    it 'assigns all product groups to @product_groups' do
      group = FactoryGirl.create(:product_group)
      get :index
      expect(assigns(:product_groups)).to include(group)
    end
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
