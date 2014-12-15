require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::CountriesController do
  let(:website) { FactoryGirl.create(:website) }

  before do
    Website.delete_all
    logged_in_as_admin
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET index' do
    it 'assigns all countries to @countries in alphabet order' do
      zambia = FactoryGirl.create(:country, name: 'Zambia')
      austria = FactoryGirl.create(:country, name: 'Austria')
      get :index
      expect(assigns(:countries).first).to eq austria
      expect(assigns(:countries).last).to eq zambia
    end
  end

  describe 'POST create' do
    context 'when save succeeds' do
      before { allow_any_instance_of(Country).to receive(:save).and_return(true) }

      it 'redirects to admin countries page' do
        post :create, country: Country.new.attributes
        expect(response).to redirect_to admin_countries_path
      end
    end
  end

  describe 'PATCH update' do
    let(:country) { FactoryGirl.create(:country) }

    context 'when update succeeds' do
      before { allow_any_instance_of(Country).to receive(:update_attributes).and_return(true) }

      def patch_update
        patch :update, id: country.id, country: country.attributes
      end

      it 'redirects to admin countries page' do
        patch_update
        expect(response).to redirect_to admin_countries_path
      end
    end
  end

  describe 'DELETE destroy' do
  end
end
