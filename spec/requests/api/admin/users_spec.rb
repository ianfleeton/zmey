require 'rails_helper'

describe 'Admin users API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    let(:json)              { JSON.parse(response.body) }
    let(:num_items)         { 1 }
    let(:email)             { nil }

    # +more_setup+ lambda allows more setup in the outer before block.
    let(:more_setup)        { nil }

    before do
      num_items.times do |x|
        FactoryGirl.create(:user)
      end

      @user1 = User.first

      more_setup.try(:call)

      get '/api/admin/users', email: email
    end

    context 'with users' do
      it 'returns users for the website' do
        expect(json['users'].length).to eq 2 # 1 set up + admin
        user = json['users'][0]
        expect(user['id']).to eq @user1.id
        expect(user['href']).to eq api_admin_user_url(@user1)
        expect(user['name']).to eq @user1.name
        expect(user['email']).to eq @user1.email
      end

      it 'returns 200 OK' do
        expect(response.status).to eq 200
      end
    end

    context 'with email set' do
      let(:email) { "#{SecureRandom.hex}@example.org" }

      let!(:more_setup) {->{
        @matching_user = FactoryGirl.create(:user)
        @matching_user.email = email
        @matching_user.save
      }}

      it 'returns the matching email' do
        expect(json['users'].length).to eq 1
        expect(json['users'][0]['email']).to eq @matching_user.email
      end
    end

    context 'with no matching users' do
      let(:email) { 'nonexistent@example.org' }

      it 'returns 200 OK' do
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        expect(json['users'].length).to eq 0
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
