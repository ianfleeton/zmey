require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET new' do
    let(:order) { FactoryGirl.create(:order) }

    it 'finds and assigns the order from the order_id param' do
      get :new, order_id: order.id
      expect(assigns(:order)).to eq order
    end
  end
end
