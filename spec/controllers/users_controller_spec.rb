require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "POST create" do
    let(:user_params) {
      {
        email: "#{SecureRandom.hex}@example.org",
        name: "Customer",
        password: "secret",
        password_confirmation: "secret"
      }
    }

    it "creates a new user" do
      expect { post_create }.to change { User.count }.by(1)
    end

    def post_create
      post :create, params: {user: user_params}
    end
  end
end
