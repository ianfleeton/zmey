require 'spec_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin users API' do
  before do
    prepare_api_website
    Api::Admin::AdminController.any_instance.stub(:authenticated_api_key).and_return(@api_key)
  end

  describe 'GET index' do
    context 'with users' do
      before do
        @user1 = FactoryGirl.create(:user, website_id: @website.id)
        @user2 = FactoryGirl.create(:user)
      end

      it 'returns users for the website' do
        get 'api/admin/users'

        users = JSON.parse(response.body)

        expect(users['users'].length).to eq 1
        expect(users['users'][0]['id']).to eq @user1.id
        expect(users['users'][0]['name']).to eq @user1.name
        expect(users['users'][0]['email']).to eq @user1.email
      end

      it 'returns 200 OK' do
        get 'api/admin/users'
        expect(response.status).to eq 200
      end
    end

    context 'with no users' do
      it 'returns 200 OK' do
        get 'api/admin/users'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get 'api/admin/users'
        users = JSON.parse(response.body)
        expect(users['users'].length).to eq 0
      end
    end
  end
end
