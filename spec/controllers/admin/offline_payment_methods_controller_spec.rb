require 'rails_helper'

RSpec.describe Admin::OfflinePaymentMethodsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'POST create' do
    let(:name) { SecureRandom.hex }
    let(:valid_params) { {'offline_payment_method' => {'name' => name}} }
    let(:invalid_params) { {'offline_payment_method' => {'name' => ''}} }

    before { post :create, params: params }

    context 'with valid params' do
      let(:params) { valid_params }

      it 'creates a new offline payment method with the given params' do
        expect(OfflinePaymentMethod.find_by(name: name)).to be
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.offline_payment_methods.create.created')
      end

      it 'redirects to the offline payment method index' do
        expect(response).to redirect_to admin_offline_payment_methods_path
      end
    end
  end

  describe 'DELETE destroy' do
    let(:opm) { FactoryBot.create(:offline_payment_method) }

    before do
      delete :destroy, params: { id: opm.id }
    end

    it 'destroys the payment method' do
      expect(OfflinePaymentMethod.find_by(id: opm.id)).to be_nil
    end

    it 'redirects to index' do
      expect(response).to redirect_to admin_offline_payment_methods_path
    end
  end
end
