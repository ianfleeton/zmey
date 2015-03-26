require 'rails_helper'

RSpec.describe Admin::NominalCodesController, type: :controller do
  before do
    FactoryGirl.create(:website)
    logged_in_as_admin
  end

  describe 'GET index' do
    it 'populates @nominal_codes with codes in order' do
      NominalCode.create!(code: 'Z', description: 'A code')
      NominalCode.create!(code: 'A', description: 'A code')
      get :index
      expect(assigns(:nominal_codes).first.code).to eq 'A'
      expect(assigns(:nominal_codes).last.code).to eq 'Z'
    end
  end

  describe 'POST create' do
    let(:code) { 'CODE' }
    let(:description) { 'Description' }

    before do
      post :create, nominal_code: { code: code, description: description }
    end

    it 'creates a nominal code' do
      expect(NominalCode.find_by(code: code, description: description)).to be
    end
  end

  describe 'GET edit' do
    let(:nominal_code) { FactoryGirl.create(:nominal_code) }

    before do
      get :edit, id: nominal_code.id
    end

    it 'assigns @nominal_code' do
      expect(assigns(:nominal_code)).to eq nominal_code
    end
  end
end
