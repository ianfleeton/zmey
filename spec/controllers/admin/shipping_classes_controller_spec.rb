require 'rails_helper'

RSpec.describe Admin::ShippingClassesController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET index' do
    it 'assigns all shipping classes to @shipping_classes ordered by name' do
      sc1 = FactoryGirl.create(:shipping_class, name: 'z')
      sc2 = FactoryGirl.create(:shipping_class, name: 'a')
      get :index
      expect(assigns(:shipping_classes).first).to eq sc2
      expect(assigns(:shipping_classes).last).to eq sc1
    end
  end
end
