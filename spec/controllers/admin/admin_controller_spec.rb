require "rails_helper"

RSpec.describe Admin::AdminController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "GET index" do
    it "succeeds" do
      get :index
      expect(response).to be_ok
    end
  end
end
