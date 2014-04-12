require 'spec_helper'

describe Api::Admin::OrdersController do
  before { logged_in_as_admin }

  describe 'GET index' do
    it 'assigns all orders for the website to @orders' do
      pending 'Make me into a request spec'
      website = FactoryGirl.create(:website)
      o1 = FactoryGirl.build(:order)
      o2 = FactoryGirl.build(:order)
      website.orders << o1
      website.orders << o2
      controller.stub(:website).and_return(website)
      get :index, format: :json
      expect(assigns(:orders)).to match_array([o1, o2])
    end
  end
end
