require 'spec_helper'

describe Admin::AdminController do
  before { logged_in_as_admin }

  describe 'GET index' do
    it 'succeeds' do
      get :index
      expect(response).to be_success
    end
  end
end
