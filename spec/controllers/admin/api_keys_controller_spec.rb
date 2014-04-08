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

  describe 'GET new' do
    it 'assigns a new ApiKey to @api_key' do
      get :new
      expect(assigns(:api_key)).to be_instance_of ApiKey
    end
  end

  describe 'POST create' do
    let(:name) { SecureRandom.hex }
    let(:valid_params) { {'api_key' => {'name' => name}} }
    let(:invalid_params) { {'api_key' => {'name' => ''}} }
    let(:current_user) { FactoryGirl.create(:admin) }

    before do
      controller.stub(:current_user).and_return(current_user)
      post :create, params
    end

    context 'with valid params' do
      let(:params) { valid_params }

      it 'creates a new API key with the given params linked to current_user' do
        expect(ApiKey.find_by(user: current_user, name: name)).to be
      end

      it 'assigns @api_key' do
        expect(assigns(:api_key)).to eq ApiKey.find_by(name: name)
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.api_keys.create.flash.created')
      end

      it 'redirects to the API key index' do
        expect(response).to redirect_to admin_api_keys_path
      end
    end

    context 'with invalid params' do
      let(:params) { invalid_params }

      it 'renders new' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET retrieve' do
    let(:key_name) { SecureRandom.hex }
    let(:api_key)  { ApiKey.new }

    before do
      api_key
      controller.stub(:authenticate_with_http_basic).and_return user
      get :retrieve, 'name' => key_name
    end

    context 'with successful authentication' do
      let(:user) { FactoryGirl.create(:user) }

      context 'with key matching given name found for user' do
        let(:api_key) { FactoryGirl.create(:api_key, name: key_name, user_id: user.id) }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'assigns the key to @api_key' do
          expect(assigns(:api_key)).to eq api_key
        end
      end

      context 'with no key found' do
        it 'responds not found' do
          expect(response).to be_not_found
        end
      end
    end

    context 'with failed authentication' do
      let(:user) { nil }

      it 'responds unauthorized' do
        expect(response.status).to eq 401
      end
    end
  end
end
