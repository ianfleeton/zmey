require "rails_helper"

RSpec.describe Admin::ApiKeysController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "POST create" do
    let(:name) { SecureRandom.hex }
    let(:valid_params) { {"api_key" => {"name" => name}} }
    let(:invalid_params) { {"api_key" => {"name" => ""}} }
    let(:current_user) { FactoryBot.create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      post :create, params: params
    end

    context "with valid params" do
      let(:params) { valid_params }

      it "creates a new API key with the given params linked to current_user" do
        expect(ApiKey.find_by(user_id: current_user.id, name: name)).to be
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq I18n.t("controllers.admin.api_keys.create.flash.created")
      end

      it "redirects to the API key index" do
        expect(response).to redirect_to admin_api_keys_path
      end
    end
  end

  describe "GET retrieve" do
    let(:key_name) { SecureRandom.hex }
    let(:api_key) { ApiKey.new }

    before do
      api_key
      allow(controller).to receive(:authenticate_with_http_basic).and_return user
      get :retrieve, params: {"name" => key_name}
    end

    context "with successful authentication" do
      let(:user) { FactoryBot.create(:user) }

      context "with key matching given name found for user" do
        let(:api_key) { FactoryBot.create(:api_key, name: key_name, user_id: user.id) }

        it "succeeds" do
          expect(response).to be_ok
        end
      end

      context "with no key found" do
        it "responds not found" do
          expect(response).to be_not_found
        end
      end
    end

    context "with failed authentication" do
      let(:user) { nil }

      it "responds unauthorized" do
        expect(response.status).to eq 401
      end
    end
  end
end
