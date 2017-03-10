require 'rails_helper'

RSpec.describe Admin::NominalCodesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'POST create' do
    let(:code) { 'CODE' }
    let(:description) { 'Description' }

    before do
      post :create, params: { nominal_code: { code: code, description: description } }
    end

    it 'creates a nominal code' do
      expect(NominalCode.find_by(code: code, description: description)).to be
    end
  end
end
