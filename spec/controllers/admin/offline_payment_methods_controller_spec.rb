require 'rails_helper'

RSpec.describe Admin::OfflinePaymentMethodsController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    logged_in_as_admin
  end

  describe 'GET index' do
    it 'assigns all methods to @offline_payment_methods' do
      opm = FactoryGirl.create(:offline_payment_method)
      get :index
      expect(assigns(:offline_payment_methods)).to include(opm)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'assigns a new method as @offline_payment_method' do
      expect(assigns(:offline_payment_method)).to be_kind_of OfflinePaymentMethod
    end
  end

  describe 'POST create' do
    let(:name) { SecureRandom.hex }
    let(:valid_params) { {'offline_payment_method' => {'name' => name}} }
    let(:invalid_params) { {'offline_payment_method' => {'name' => ''}} }

    before { post :create, params }

    context 'with valid params' do
      let(:params) { valid_params }

      it 'creates a new offline payment method with the given params' do
        expect(OfflinePaymentMethod.find_by(name: name)).to be
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq I18n.t('controllers.admin.offline_payment_methods.create.flash.created')
      end

      it 'redirects to the offline payment method index' do
        expect(response).to redirect_to admin_offline_payment_methods_path
      end
    end

    context 'with invalid params' do
      let(:params) { invalid_params }

      it 'assigns @offline_payment_method' do
        expect(assigns(:offline_payment_method)).to be_kind_of OfflinePaymentMethod
      end

      it 'renders new' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'DELETE destroy' do
    let(:opm) { FactoryGirl.create(:offline_payment_method) }

    before do
      delete :destroy, id: opm.id
    end

    it 'destroys the payment method' do
      expect(OfflinePaymentMethod.find_by(id: opm.id)).to be_nil
    end

    it 'redirects to index' do
      expect(response).to redirect_to admin_offline_payment_methods_path
    end
  end
end
