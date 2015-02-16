require 'rails_helper'
require_relative 'shared_examples/shipping.rb'

RSpec.describe CheckoutController, type: :controller do
  let(:website) { FactoryGirl.create(:website) }
  before { allow(controller).to receive(:website).and_return(website) }

  shared_examples_for 'a checkout advancer' do |method, action, params=nil|
    let(:has_checkout_details) { true }
    let(:billing_address) { FactoryGirl.create(:address) }
    let(:delivery_address) { FactoryGirl.create(:address) }

    before do
      allow(controller).to receive(:has_checkout_details?).and_return(has_checkout_details)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address).and_return(delivery_address)
      send(method, action, params)
    end

    context 'without name, phone and email set in session' do
      let(:has_checkout_details) { false }
      it { should redirect_to checkout_details_path }
    end

    context 'without billing details' do
      let(:billing_address) { nil }
      it { should redirect_to billing_details_path }
    end

    context 'without delivery details' do
      let(:delivery_address) { nil }
      it { should redirect_to delivery_details_path }
    end

    context 'with all details' do
      it { should redirect_to confirm_checkout_path }
    end
  end

  describe 'GET index' do
    context 'with empty basket' do
      before { get :index }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      before { add_items_to_basket }

      it_behaves_like 'a checkout advancer', :get, :index
    end
  end

  describe 'GET details' do
    let(:current_user) { User.new }
    let(:name) { nil }
    let(:email) { nil }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      session[:name] = name
      session[:email] = email
      get :details
    end

    it { should render_with_layout 'basket_checkout' }

    context 'when logged in' do
      let(:current_user) { FactoryGirl.create(:user, name: SecureRandom.hex) }

      context 'when details blank' do
        it 'populates name and email from user account' do
          expect(session[:name]).to eq current_user.name
          expect(session[:email]).to eq current_user.email
        end
      end

      context 'when details present' do
        let(:name) { 'untouched' }
        let(:email) { 'untouched' }

        it 'leaves details untouched' do
          expect(session[:name]).to eq name
          expect(session[:email]).to eq email
        end
      end
    end
  end

  describe 'POST save_details' do
    context 'with valid details' do
      before { post :save_details, name: 'n', phone: '1', email: 'x' }

      it { should set_session(:name).to('n') }
      it { should set_session(:phone).to('1') }
      it { should set_session(:email).to('x') }

      it_behaves_like 'a checkout advancer', :post, :save_details, name: 'n', phone: '1', email: 'x'
    end
  end

  shared_examples_for 'an address prefiller' do
    it 'assigns @address' do
      expect(assigns(:address)).to be_instance_of Address
    end

    it 'prefills some of the address from session details' do
      expect(assigns(:address).full_name).to eq 'n'
      expect(assigns(:address).phone_number).to eq '1'
      expect(assigns(:address).email_address).to eq 'x'
    end

    it 'sets the address country as United Kingdom' do
      expect(assigns(:address).country).to eq uk
    end
  end

  shared_examples_for 'a customer details user' do
    context 'without name, phone and email set in session' do
      let(:name) { '' }
      it { should redirect_to checkout_path }
    end
  end

  describe 'GET billing' do
    let(:billing_address_id) { nil }

    context 'with empty basket' do
      before { get :billing }
      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      let(:addresses) { [] }
      let(:name) { 'n' }
      let(:phone) { '1' }
      let(:email) { 'x' }
      let!(:uk) { FactoryGirl.create(:country, name: 'United Kingdom') }

      before do
        add_items_to_basket
        session[:name] = name
        session[:phone] = phone
        session[:email] = email
        session[:billing_address_id] = billing_address_id
        allow_any_instance_of(User).to receive(:addresses).and_return addresses
        get :billing
      end

      it_behaves_like 'a customer details user'

      context 'with existing billing address' do
        let(:billing_address) { FactoryGirl.create(:address) }
        let(:billing_address_id) { billing_address.id }

        it { should respond_with(200) }
        it { should render_with_layout 'basket_checkout' }

        it 'assigns @address to the billing address' do
          expect(assigns(:address)).to eq billing_address
        end
      end

      context 'with no existing billing address' do
        let(:billing_address_id) { nil }

        context 'when user has addresses' do
          let(:addresses) { [Address.new] }

          it { should set_session(:source).to('billing') }
          it { should redirect_to choose_billing_address_addresses_path }
        end

        context 'when user has no addresses' do
          it_behaves_like 'an address prefiller'
        end
      end
    end
  end

  shared_examples_for 'an address/user associator' do |method|
    let(:billing_address) { nil }
    let(:delivery_address) { nil }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address).and_return(delivery_address)
      post method, address: address.attributes
    end

    context 'when signed in' do
      let(:current_user) { FactoryGirl.create(:user) }

      context 'with new address' do
        let(:address) { FactoryGirl.build(:address) }

        it 'associates address with user' do
          expect(Address.last.user).to eq current_user
        end
      end

      context 'with existing address' do
        let(:address) { FactoryGirl.create(:address) }
        let(:billing_address) { address }
        let(:delivery_address) { address }

        it 'associates address with user' do
          expect(address.reload.user).to eq current_user
        end
      end
    end
  end

  ATTRIBUTES_TO_SAVE = [
    'address_line_1', 'address_line_2', 'address_line_3',
    'company', 'country_id', 'county', 'postcode', 'town_city'
  ]

  describe 'POST save_billing' do
    let(:address) { FactoryGirl.build(:random_address) }
    let(:billing_address) { nil }
    let(:deliver_here) { nil }
    let(:session_billing_address_id) { nil }
    let(:session_delivery_address_id) { nil }

    before do
      allow(controller).to receive(:billing_address).and_return(billing_address)
      session[:billing_address_id] = session_billing_address_id
      session[:delivery_address_id] = session_delivery_address_id
      post :save_billing, address: address.attributes, deliver_here: deliver_here
    end

    context 'when billing address found' do
      let(:billing_address) { FactoryGirl.create(:address) }

      it 'updates the billing address' do
        expect(billing_address.reload.attributes.slice(*ATTRIBUTES_TO_SAVE))
          .to eq address.attributes.slice(*ATTRIBUTES_TO_SAVE)
      end

      context 'when deliver_here checked' do
        let(:deliver_here) { '1' }

        it 'sets the session delivery_address_id to the billing address' do
          expect(session[:delivery_address_id]).to eq billing_address.reload.id
        end
      end
    end

    context 'when updating and billing and delivery address are the same' do     
      let(:billing_address) { FactoryGirl.create(:address) }
      let(:session_billing_address_id) { billing_address.id }
      let(:session_delivery_address_id) { billing_address.id }

      it 'makes a copy of the billing address' do
        expect(session[:billing_address_id]).to be
        expect(session[:billing_address_id]).to_not eq billing_address.id
      end
    end

    context 'when billing address not found' do
      let(:billing_address) { nil }

      it 'creates a new address' do
        expect(Address.find_by(address_line_1: address.address_line_1)).to be
      end

      it { should set_session(:billing_address_id) }
    end

    context 'when create/update succeeds' do
      it_behaves_like 'a checkout advancer', :post, :save_billing, { address: FactoryGirl.build(:address).attributes }
      it_behaves_like 'an address/user associator', :save_billing
    end

    context 'when create/update fails' do
      let(:address) { Address.new }
      it { should render_template 'billing' }
    end
  end

  describe 'GET delivery' do
    let(:delivery_address_id) { nil }

    context 'with empty basket' do
      before { get :delivery }
      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      let(:addresses) { [] }
      let(:name) { 'n' }
      let(:phone) { '1' }
      let(:email) { 'x' }
      let!(:uk) { FactoryGirl.create(:country, name: 'United Kingdom') }

      before do
        add_items_to_basket
        session[:name] = name
        session[:phone] = phone
        session[:email] = email
        session[:delivery_address_id] = delivery_address_id
        allow_any_instance_of(User).to receive(:addresses).and_return addresses
        get :delivery
      end

      it_behaves_like 'a customer details user'

      context 'with existing delivery address' do
        let(:delivery_address) { FactoryGirl.create(:address) }
        let(:delivery_address_id) { delivery_address.id }

        it { should respond_with(200) }
        it { should render_with_layout 'basket_checkout' }

        it 'assigns @address to the delivery address' do
          expect(assigns(:address)).to eq delivery_address
        end
      end

      context 'with no existing delivery address' do
        let(:delivery_address_id) { nil }

        context 'when user has addresses' do
          let(:addresses) { [Address.new] }

          it { should set_session(:source).to('delivery') }
          it { should redirect_to choose_delivery_address_addresses_path }
        end

        context 'when user has no addresses' do
          it_behaves_like 'an address prefiller'
        end
      end
    end
  end

  describe 'POST save_delivery' do
    let(:address) { FactoryGirl.build(:random_address) }
    let(:delivery_address) { nil }
    let(:session_billing_address_id) { nil }
    let(:session_delivery_address_id) { nil }

    before do
      allow(controller).to receive(:delivery_address).and_return(delivery_address)
      session[:billing_address_id] = session_billing_address_id
      session[:delivery_address_id] = session_delivery_address_id
      post :save_delivery, address: address.attributes 
    end

    context 'when delivery address found' do
      let(:delivery_address) { FactoryGirl.create(:address) }

      it 'updates the delivery address' do
        expect(delivery_address.reload.attributes.slice(*ATTRIBUTES_TO_SAVE))
          .to eq address.attributes.slice(*ATTRIBUTES_TO_SAVE)
      end
    end

    context 'when updating and billing and delivery address are the same' do     
      let(:delivery_address) { FactoryGirl.create(:address) }
      let(:session_billing_address_id) { delivery_address.id }
      let(:session_delivery_address_id) { delivery_address.id }

      it 'makes a copy of the delivery address' do
        expect(session[:delivery_address_id]).to be
        expect(session[:delivery_address_id]).to_not eq delivery_address.id
      end
    end

    context 'when delivery address not found' do
      let(:delivery_address) { nil }

      it 'creates a new address' do
        expect(Address.find_by(address_line_1: address.address_line_1)).to be
      end

      it { should set_session(:delivery_address_id) }
    end

    context 'when create/update succeeds' do
      it_behaves_like 'a checkout advancer', :post, :save_delivery, { address: FactoryGirl.build(:address).attributes }
      it_behaves_like 'an address/user associator', :save_delivery
    end

    context 'when create/update fails' do
      let(:address) { Address.new }
      it { should render_template 'delivery' }
    end
  end

  describe 'GET confirm' do
    context 'with empty basket' do
      before { get :confirm }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      let(:billing_address) { FactoryGirl.create(:address) }
      let(:delivery_address) { FactoryGirl.create(:address) }
      let(:billing_address_id) { billing_address.id }
      let(:delivery_address_id) { delivery_address.id }

      before do
        session[:billing_address_id] = billing_address_id
        session[:delivery_address_id] = delivery_address_id
        add_items_to_basket
        get 'confirm'
      end

      it_behaves_like 'a shipping class setter', :get, :confirm
      it_behaves_like 'a shipping amount setter', :get, :confirm
      it_behaves_like 'a discounts calculator', :get, :confirm

      it { should render_with_layout 'basket_checkout' }
      it { should use_before_action :remove_invalid_discounts }

      it 'assigns billing address to @billing_address' do
        expect(assigns(:billing_address)).to eq billing_address
      end

      it 'assigns delivery address to @delivery_address' do
        expect(assigns(:delivery_address)).to eq delivery_address
      end

      context 'without a billing address' do
        let(:billing_address_id) { nil }
        it { should redirect_to checkout_path }
      end

      context 'without a delivery address' do
        let(:delivery_address_id) { nil }
        it { should redirect_to checkout_path }
      end
    end
  end

  describe 'POST place_order' do
    let(:billing_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }
    let(:delivery_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }
    let(:basket) { FactoryGirl.build(:basket) }
    let(:t_shirt) { FactoryGirl.create(:product, weight: 0.2) }
    let(:jeans) { FactoryGirl.create(:product, weight: 0.35) }
    let(:only_accept_payment_on_account?) { false }

    before do
      basket.basket_items << FactoryGirl.build(:basket_item, product_id: t_shirt.id, quantity: 2)      
      basket.basket_items << FactoryGirl.build(:basket_item, product_id: jeans.id, quantity: 1)
      allow(Basket).to receive(:new).and_return(basket)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address).and_return(delivery_address)
      allow(website).to receive(:only_accept_payment_on_account?)
        .and_return(only_accept_payment_on_account?)
    end

    it_behaves_like 'a discounts calculator', :post, :place_order

    it_behaves_like 'a shipping class setter', :post, :place_order

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

    it 'copies the billing address to the order' do
      expect_any_instance_of(Order).to receive(:copy_billing_address)
        .with(billing_address).and_call_original
      post 'place_order'
    end

    it 'copies the delivery address to the order' do
      expect_any_instance_of(Order).to receive(:copy_delivery_address)
        .with(delivery_address).and_call_original
      post 'place_order'
    end

    context 'without a billing address' do
      let(:billing_address) { nil }
      before { post :place_order }
      it { should redirect_to checkout_path }
    end

    context 'without a delivery address' do
      let(:delivery_address) { nil }
      before { post :place_order }
      it { should redirect_to checkout_path }
    end

    context 'with a shipping class' do
      let!(:shipping_class) { FactoryGirl.create(:shipping_class, name: 'Royal Mail') }
      before do
        allow(controller).to receive(:shipping_class).and_return(shipping_class)
        post :place_order
      end
      it 'records the shipping class name as the shipping method' do
        expect(Order.last.shipping_method).to eq 'Royal Mail'
      end
    end

    context 'without a shipping class' do
      before { post :place_order }
      it 'records "Standard Shipping" as the shipping method' do
        expect(Order.last.shipping_method).to eq 'Standard Shipping'
      end
    end
  end

  def add_items_to_basket
    basket = FactoryGirl.create(:basket)
    FactoryGirl.create(:basket_item, basket_id: basket.id)
    allow(controller).to receive(:basket).and_return(basket)
  end
end
