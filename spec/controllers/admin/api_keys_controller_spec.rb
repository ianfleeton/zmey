require 'spec_helper'

describe Admin::ApiKeysController do
  before { logged_in_as_admin }

  describe 'GET index' do
    it 'assigns keys belonging to the current user' do
      user = FactoryGirl.create(:user)
      api_key = FactoryGirl.create(:api_key, user_id: user.id)
      controller.stub(:current_user).and_return(user)
      get :index
      expect(assigns(:api_keys)).to match_array [api_key]
    end
  end
end
