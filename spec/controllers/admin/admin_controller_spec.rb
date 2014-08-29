require 'rails_helper'

describe Admin::AdminController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    logged_in_as_admin
  end

  describe 'GET index' do
    it 'succeeds' do
      get :index
      expect(response).to be_success
    end
  end
end
