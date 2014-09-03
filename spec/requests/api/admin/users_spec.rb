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
        get '/api/admin/users'

        users = JSON.parse(response.body)

        expect(users['users'].length).to eq 1
        user = users['users'][0]
        expect(user['id']).to eq @user1.id
        expect(user['href']).to eq api_admin_user_url(@user1)
        expect(user['name']).to eq @user1.name
        expect(user['email']).to eq @user1.email
      end

      it 'returns 200 OK' do
        get '/api/admin/users'
        expect(response.status).to eq 200
      end
    end

    context 'with no users' do
      it 'returns 200 OK' do
        get '/api/admin/users'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get '/api/admin/users'
        users = JSON.parse(response.body)
        expect(users['users'].length).to eq 0
      end
    end
  end

  describe 'GET show' do
    context 'when user found' do
      let(:manages_website_id) { nil }

      before do
        @user = FactoryGirl.create(:user, website_id: @website.id, manages_website_id: manages_website_id)
      end

      it 'returns 200 OK' do
        get api_admin_user_path(@user)
        expect(response.status).to eq 200
      end

      context 'when user does not manage current website' do
        it 'sets manager to false' do
          get api_admin_user_path(@user)
          user = JSON.parse(response.body)
          expect(user['user']['manager']).to be_falsey
        end
      end

      context 'when user manages current website' do
        let(:manages_website_id) { @website.id }

        it 'sets manager to true' do
          get api_admin_user_path(@user)
          user = JSON.parse(response.body)
          expect(user['user']['manager']).to be_truthy
        end
      end
    end

    context 'when no user' do
      it 'returns 404 Not Found' do
        get '/api/admin/users/0'
        expect(response.status).to eq 404
      end
    end
  end
end
