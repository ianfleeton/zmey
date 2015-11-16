require 'rails_helper'
require_relative 'shared_examples/shipping.rb'
require_relative 'shared_examples/shopping_suspended.rb'

RSpec.describe BasketController, type: :controller do
  let(:website) { FactoryGirl.create(:website, name: 'www', email: 'anon@example.org', domain: 'example.org') }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  it_behaves_like 'a suspended shop bouncer'

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

    context 'when xhr' do
      it 'responds 200 OK' do
        xhr :post, :add_update_multiple
        expect(response.status).to eq 200
      end
    end

    context 'when not xhr' do
      it 'redirects to the basket' do
        post :add_update_multiple
        expect(response).to redirect_to(basket_path)
      end
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

    context 'with checkout.x param set (in case of <button>)' do
      before { post :update, 'checkout.x': '10' }

      it { should redirect_to checkout_path }
    end

    context 'xhr request' do
      before { xhr :post, :update }

      it { should respond_with(204) }
    end
  end

  describe 'POST save_and_email' do
    let(:email_address) { 'shopper@example.org' }

    it 'clones the basket and its contents' do
      basket = double(Basket, apply_shipping?: false, shipping_supplement: 0)
      allow(controller).to receive(:basket).and_return basket
      expect(basket).to receive(:deep_clone)
        .and_return(Basket.new(token: 'token'))
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

    it 'sets a flash notice' do
      post :save_and_email, email_address: email_address
      expect(flash[:notice]).to eq I18n.t('controllers.basket.save_and_email.email_sent', email_address: email_address)
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
