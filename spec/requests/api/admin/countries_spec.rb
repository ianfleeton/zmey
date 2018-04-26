require 'rails_helper'

describe 'Admin countries API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    context 'with countries' do
      before do
        @country1 = FactoryBot.create(:country)
        @country2 = FactoryBot.create(:country)
      end

      it 'returns all countries' do
        get '/api/admin/countries'

        countries = JSON.parse(response.body)

        # First country is created with the website fixture.
        expect(countries['countries'].length).to eq 3

        expect(countries['countries'][1]['id']).to eq @country1.id
        expect(countries['countries'][1]['href']).to eq api_admin_country_url(@country1)
        expect(countries['countries'][1]['name']).to eq @country1.name
      end

      it 'returns 200 OK' do
        get '/api/admin/countries'
        expect(response.status).to eq 200
      end
    end

    context 'with no countries' do
      before do
        Country.delete_all
      end

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
