require 'rails_helper'

describe 'Admin users API' do
  before do
    prepare_api_website
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
        user = users['users'][0]
        expect(user['id']).to eq @user1.id
        expect(user['href']).to eq api_admin_user_url(@user1)
        expect(user['name']).to eq @user1.name
        expect(user['email']).to eq @user1.email
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
