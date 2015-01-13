require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:website) { FactoryGirl.create(:website) }
  before { allow(controller).to receive(:website).and_return(website) }

  describe 'GET index' do
    context 'with empty basket' do
      before { get :index }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      before do
        basket = FactoryGirl.create(:basket)
        FactoryGirl.create(:basket_item, basket_id: basket.id)
        allow(controller).to receive(:basket).and_return(basket)
      end

      context 'with name, phone and email set in session' do
        before do
          session[:name] = 'A. Customer'
          session[:phone] = '01234 567890'
          session[:email] = 'customer@example.com'
          get :index
        end

        it { should redirect_to billing_details_path }
      end

      context 'without name, phone and email set in session' do
        before do
          get :index
        end

        it { should render_with_layout 'basket_checkout' }
      end
    end
  end

  describe 'POST save_details' do
    context 'with valid details' do
      before { post :save_details, name: 'n', phone: '1', email: 'x' }

      it { should set_session(:name).to('n') }
      it { should set_session(:phone).to('1') }
      it { should set_session(:email).to('x') }

      it { should redirect_to billing_details_path }
    end
  end

  describe 'GET confirm' do
    context 'with empty basket' do
      before { get :confirm }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      before do
        basket = FactoryGirl.create(:basket)
        FactoryGirl.create(:basket_item, basket_id: basket.id)
        allow(controller).to receive(:basket).and_return(basket)
      end

      it_behaves_like 'a shipping class setter', :get, :confirm
      it_behaves_like 'a discounts calculator', :get, :confirm

      context 'with an address' do
        before do
          session[:address_id] = FactoryGirl.create(:address).id
          get :confirm
        end

        it { should render_with_layout 'basket_checkout' }
        it { should use_before_action :remove_invalid_discounts }
      end
    end
  end
end
