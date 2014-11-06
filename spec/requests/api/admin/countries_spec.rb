require 'rails_helper'

describe 'Admin countries API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    context 'with countries' do
      before do
        @country1 = FactoryGirl.create(:country, website_id: @website.id)
        @country2 = FactoryGirl.create(:country)
      end

      it 'returns countries for the website' do
        get '/api/admin/countries'

        countries = JSON.parse(response.body)

        expect(countries['countries'].length).to eq 1
        expect(countries['countries'][0]['id']).to eq @country1.id
        expect(countries['countries'][0]['href']).to eq api_admin_country_url(@country1)
        expect(countries['countries'][0]['name']).to eq @country1.name
      end

      it 'returns 200 OK' do
        get '/api/admin/countries'
        expect(response.status).to eq 200
      end
    end

    context 'with no countries' do
      it 'returns 200 OK' do
        get '/api/admin/countries'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get '/api/admin/countries'
        countries = JSON.parse(response.body)
        expect(countries['countries'].length).to eq 0
      end
    end
  end
end
