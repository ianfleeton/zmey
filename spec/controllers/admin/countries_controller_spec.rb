require 'spec_helper'
require 'shared_examples_for_controllers'

describe Admin::CountriesController do
  let(:website) { FactoryGirl.create(:website) }

  before do
    Website.delete_all
    logged_in_as_admin
    controller.stub(:website).and_return(website)
  end

  describe 'GET index' do
    it_behaves_like 'a website owned objects finder', :country
  end

  describe 'POST create' do
    context 'when save succeeds' do
      before { Country.any_instance.stub(:save).and_return(true) }

      it 'redirects to admin countries page' do
        post :create, country: Country.new.attributes
        expect(response).to redirect_to admin_countries_path
      end
    end
  end

  describe 'PATCH update' do
    let(:country) { FactoryGirl.create(:country, website: website) }

    context 'when update succeeds' do
      before { Country.any_instance.stub(:update_attributes).and_return(true) }

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
