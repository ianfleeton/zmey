require 'spec_helper'

describe BasketController do
  let(:website) { FactoryGirl.create(:website, name: 'www', email: 'anon@example.org', domain: 'example.org') }
  let(:valid_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }

  before do
    controller.stub(:website).and_return(website)
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
      Basket.stub(:new).and_return(basket)
    end

    context 'with an address' do
      before do
        controller.stub(:find_delivery_address).and_return(valid_address)
      end

      it 'deletes a previous unpaid order if one exists' do
        controller.should_receive(:delete_previous_unpaid_order_if_any)
        post 'place_order'
      end

      it "records the customer's IP address" do
        post 'place_order'
        expect(assigns(:order).ip_address).to eq '0.0.0.0'
      end

      it 'creates an order line for each basket item' do
        post 'place_order'
        expect(assigns(:order).order_lines.count).to eq 2
      end

      it 'records the weight of the products' do
        post 'place_order'
        expect(assigns(:order).weight).to eq 0.75
      end
    end
  end

  describe 'POST save_and_email' do
    let(:email_address) { 'shopper@example.org' }

    it 'clones the basket and its contents' do
      basket = double(Basket)
      controller.stub(:basket).and_return basket
      basket.should_receive(:deep_clone).with(include: :basket_items)
        .and_return(double(Basket, token: 'token'))
      post :save_and_email, email_address: email_address
    end

    it 'sends an email to params[:email_address] with the cloned basket' do
      cloned_basket = double(Basket)
      Basket.any_instance.stub(:deep_clone).and_return(cloned_basket)
      BasketMailer.should_receive(:saved_basket)
        .with(website, email_address, cloned_basket)
        .and_return(double(BasketMailer, deliver: true))
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
