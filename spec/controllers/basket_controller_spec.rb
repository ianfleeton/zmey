require 'rails_helper'

describe BasketController do
  let(:website) { FactoryGirl.create(:website, name: 'www', email: 'anon@example.org', domain: 'example.org') }
  let(:valid_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET index' do
    let(:our_page)   { FactoryGirl.create(:page, website_id: website.id) }
    let(:other_page) { FactoryGirl.create(:page) }

    before { get :index, page_id: page_id }

    context 'with valid params[:page_id]' do
      let(:page_id) { our_page.id }

      it 'sets @page' do
        expect(assigns(:page)).to eq our_page
      end
    end

    context 'with invalid params[:page_id]' do
      let(:page_id) { other_page.id }

      it 'sets @page' do
        expect(assigns(:page)).to be_nil
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

  describe 'POST place_order' do
    let(:basket) { FactoryGirl.build(:basket) }
    let(:t_shirt) { FactoryGirl.create(:product, weight: 0.2) }
    let(:jeans) { FactoryGirl.create(:product, weight: 0.35) }

    before do
      basket.basket_items << FactoryGirl.build(:basket_item, product_id: t_shirt.id, quantity: 2)      
      basket.basket_items << FactoryGirl.build(:basket_item, product_id: jeans.id, quantity: 1)
      allow(Basket).to receive(:new).and_return(basket)
    end

    context 'with an address' do
      before do
        allow(controller).to receive(:find_delivery_address).and_return(valid_address)
      end

      it 'deletes a previous unpaid order if one exists' do
        expect(controller).to receive(:delete_previous_unpaid_order_if_any)
        post 'place_order'
      end

      it 'records preferred delivery date' do
        date = '28/12/15'
        settings = double(Order).as_null_object
        allow(website).to receive(:preferred_delivery_date_settings).and_return(settings)
        expect_any_instance_of(Order).to receive(:record_preferred_delivery_date).with(settings, date)
        post 'place_order', preferred_delivery_date: date
      end

      it "records the customer's IP address" do
        post 'place_order'
        expect(assigns(:order).ip_address).to eq '0.0.0.0'
      end

      it 'adds the basket to the order' do
        expect_any_instance_of(Order).to receive(:add_basket).with(basket)
        post 'place_order'
      end

      it 'records the weight of the products' do
        post 'place_order'
        expect(assigns(:order).weight).to eq 0.75
      end

      it 'triggers an order_created Webhook' do
        expect(Webhook).to receive(:trigger).with('order_created', anything)
        post 'place_order'
      end
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
