require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:website) { FactoryGirl.create(:website) }
  before { allow(controller).to receive(:website).and_return(website) }

  describe 'GET index' do
    it_behaves_like 'a shipping class setter', :get, :index
    it_behaves_like 'a discounts calculator', :get, :index

    context 'with items in the basket' do
      before do
        basket = FactoryGirl.create(:basket)
        FactoryGirl.create(:basket_item, basket_id: basket.id)
        allow(controller).to receive(:basket).and_return(basket)
      end

      context 'with an address' do
        before do
          session[:address_id] = FactoryGirl.create(:address).id
          get :index
        end

        it { should render_with_layout 'basket_checkout' }
      end
    end
  end
end
