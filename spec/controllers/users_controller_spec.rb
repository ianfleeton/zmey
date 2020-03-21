require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "POST create" do
    let(:admin) { false }
    let(:user_params) {
      {
        email: "#{SecureRandom.hex}@example.org",
        name: "Customer",
        password: "secret",
        password_confirmation: "secret",
        admin: admin
      }
    }

    it "creates a new user" do
      expect { post_create }.to change { User.count }.by(1)
    end

    context "try to create admin" do
      let(:admin) { true }
      it "does not create admin" do
        post_create
        expect(User.last.admin?).to eq false
      end
    end

    def post_create
      post :create, params: {user: user_params}
    end
  end
end
