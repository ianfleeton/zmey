require 'rails_helper'

RSpec.describe Admin::CountriesController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'POST create' do
    context 'when save succeeds' do
      before { allow_any_instance_of(Country).to receive(:save).and_return(true) }

      it 'redirects to admin countries page' do
        post :create, params: { country: Country.new.attributes }
        expect(response).to redirect_to admin_countries_path
      end
    end
  end

  describe 'PATCH update' do
    let(:country) { FactoryGirl.create(:country) }

    context 'when update succeeds' do
      before { allow_any_instance_of(Country).to receive(:update_attributes).and_return(true) }

      def patch_update
        patch :update, params: { id: country.id, country: country.attributes }
      end

      it 'redirects to admin countries page' do
        patch_update
        expect(response).to redirect_to admin_countries_path
      end
    end
  end
end
