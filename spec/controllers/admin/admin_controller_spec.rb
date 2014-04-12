require 'spec_helper'

describe Admin::AdminController do
  let(:website) { mock_model(Website, :private? => false).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    logged_in_as_admin
  end

  describe 'GET index' do
    it 'succeeds' do
      get :index
      expect(response).to be_success
    end
  end
end
