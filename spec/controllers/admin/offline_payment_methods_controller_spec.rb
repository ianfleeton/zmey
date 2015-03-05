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
end
