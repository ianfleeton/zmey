require 'rails_helper'
require_relative 'shared_examples/shipping.rb'

describe BasketController do
  let(:website) { FactoryGirl.create(:website, name: 'www', email: 'anon@example.org', domain: 'example.org') }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET index' do
    let(:page)   { FactoryGirl.create(:page) }

    it_behaves_like 'a shipping class setter', :get, :index
    it_behaves_like 'a shipping amount setter', :get, :index

    context 'with page_id param set' do
      before { get :index, page_id: page_id }

      context 'with valid params[:page_id]' do
        let(:page_id) { page.id }

        it 'sets @page' do
          expect(assigns(:page)).to eq page
        end
      end

      context 'with invalid params[:page_id]' do
        let(:page_id) { page.id + 1 }

        it 'sets @page' do
          expect(assigns(:page)).to be_nil
        end
      end
    end
  end

  describe 'POST add_update_multiple' do
    context 'with no quantities' do
      it 'does not raise' do
        expect { post :add_update_multiple }.not_to raise_error
      end
    end

    it 'redirects to the basket' do
      post :add_update_multiple
      expect(response).to redirect_to(basket_path)
    end
  end

  shared_examples_for 'a shipping class updater' do |method, action|
    let(:shipping_class) { FactoryGirl.create(:shipping_class) }

    it 'sets shipping class in the session' do
      send(method, action, shipping_class_id: shipping_class.id)
      expect(session[:shipping_class_id]).to eq shipping_class.id
    end
  end

  describe 'POST update' do
    it_behaves_like 'a shipping class updater', :post, :update

    context 'with checkout param set' do
      before { post :update, checkout: 'Checkout' }

      it { should redirect_to checkout_path }
    end
  end

  describe 'POST save_and_email' do
    let(:email_address) { 'shopper@example.org' }

    it 'clones the basket and its contents' do
      basket = double(Basket)
      allow(controller).to receive(:basket).and_return basket
      expect(basket).to receive(:deep_clone)
        .and_return(double(Basket, token: 'token'))
      post :save_and_email, email_address: email_address
    end

    it 'sends an email to params[:email_address] with the cloned basket' do
      cloned_basket = double(Basket)
      allow_any_instance_of(Basket).to receive(:deep_clone).and_return(cloned_basket)
      expect(BasketMailer).to receive(:saved_basket)
        .with(website, email_address, cloned_basket)
        .and_return(double(BasketMailer, deliver_now: true))
      post :save_and_email, email_address: email_address
    end

    it 'redirects to the basket' do
      post :save_and_email, email_address: email_address
      expect(response).to redirect_to(basket_path)
    end
  end

  describe 'GET load' do
    context 'with valid token' do
      let(:basket) { FactoryGirl.create(:basket) }

      it 'sets the session basket to the matching basket' do
        get :load, token: basket.token
        expect(Basket.find(session[:basket_id])).to eq basket
      end
    end

    it 'redirects to the basket' do
      get :load, token: 'TOKEN'
      expect(response).to redirect_to(basket_path)
    end
  end
end
