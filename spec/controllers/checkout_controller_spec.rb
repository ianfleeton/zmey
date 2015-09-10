require 'rails_helper'
require_relative 'shared_examples/discounts.rb'
require_relative 'shared_examples/shipping.rb'
require_relative 'shared_examples/shopping_suspended.rb'

RSpec.describe CheckoutController, type: :controller do
  let(:website) { FactoryGirl.create(:website) }
  before { allow(controller).to receive(:website).and_return(website) }

  it_behaves_like 'a suspended shop bouncer'

  shared_examples_for 'a checkout advancer' do |method, action, params=nil|
    let(:has_checkout_details) { true }
    let(:billing_address) { FactoryGirl.create(:address) }
    let(:delivery_address) { FactoryGirl.create(:address) }
    let(:preferred_delivery_date) { '2015-02-16' }
    let(:preferred_delivery_date_settings) { nil }

    before do
      allow(controller).to receive(:has_checkout_details?).and_return(has_checkout_details)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address).and_return(delivery_address)
      allow(website).to receive(:preferred_delivery_date_settings).and_return(preferred_delivery_date_settings)
      session[:preferred_delivery_date] = preferred_delivery_date
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

    context 'without preferred delivery date' do
      let(:preferred_delivery_date) { nil }

      context 'when used' do
        let(:preferred_delivery_date_settings) { PreferredDeliveryDateSettings.new() }
        it { should redirect_to preferred_delivery_date_path }
      end

      context 'when not used' do
        it { should redirect_to confirm_checkout_path }
      end
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

      it { should set_session[:name].to('n') }
      it { should set_session[:phone].to('1') }
      it { should set_session[:email].to('x') }

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

          it { should set_session[:source].to('billing') }
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

      context 'when deliver_here checked' do
        let(:deliver_here) { '1' }

        it 'sets the session delivery_address_id to the billing address' do
          expect(session[:delivery_address_id]).to eq Address.last.id
        end
      end

      it { should set_session[:billing_address_id] }
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

          it { should set_session[:source].to('delivery') }
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

      it { should set_session[:delivery_address_id] }
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

  describe 'GET preferred_delivery_date' do
    before { get :preferred_delivery_date }
    subject { response }
    it { should be_success }
  end

  describe 'POST save_preferred_delivery_date' do
    let(:preferred_delivery_date) { '2015-02-16' }

    before do
      post :save_preferred_delivery_date, preferred_delivery_date: preferred_delivery_date
    end

    it 'records preferred delivery date in the session' do
      expect(session[:preferred_delivery_date]).to eq preferred_delivery_date
    end

    it_behaves_like 'a checkout advancer', :post, :save_preferred_delivery_date
  end

  describe 'GET confirm' do
    context 'with empty basket' do
      before { get :confirm }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      let(:billing_address) { FactoryGirl.create(:address) }
      let(:delivery_address) { FactoryGirl.create(:address) }
      let(:billing_address_id) { billing_address.try(:id) }
      let(:delivery_address_id) { delivery_address.try(:id) }

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

      it_behaves_like 'a discounts calculator', :get, :confirm

      it_behaves_like 'a shipping class setter', :get, :confirm

      it 'deletes a previous unpaid order if one exists' do
        session[:order_id] = 123
        expect(Order).to receive(:new_or_recycled).with(123).and_call_original
        get :confirm
      end

      it 'records preferred delivery date' do
        date = '28/12/15'
        session[:preferred_delivery_date] = date
        settings = double(PreferredDeliveryDateSettings).as_null_object
        allow(website).to receive(:preferred_delivery_date_settings).and_return(settings)
        expect_any_instance_of(Order).to receive(:record_preferred_delivery_date).with(settings, date)
        get :confirm
      end

      it 'redirects to preferred_delivery_date with an invalid date' do
        date = '28-12-15'
        session[:preferred_delivery_date] = date
        settings = PreferredDeliveryDateSettings.new
        allow(website).to receive(:preferred_delivery_date_settings).and_return(settings)
        get :confirm
        expect(response).to redirect_to preferred_delivery_date_path
      end

      it "records the customer's IP address" do
        expect(assigns(:order).ip_address).to eq '0.0.0.0'
      end

      it 'adds the basket to the order' do
        expect_any_instance_of(Order).to receive(:add_basket).with(@basket)
        get :confirm
      end

      it 'records the weight of the products' do
        expect(assigns(:order).weight).to eq 0.75
      end

      it 'triggers an order_created Webhook' do
        expect(Webhook).to receive(:trigger).with('order_created', anything)
        get :confirm
      end

      it 'copies the billing address to the order' do
        expect_any_instance_of(Order).to receive(:copy_billing_address)
          .with(billing_address).and_call_original
        get :confirm
      end

      it 'copies the delivery address to the order' do
        expect_any_instance_of(Order).to receive(:copy_delivery_address)
          .with(delivery_address).and_call_original
        get :confirm
      end

      context 'without a billing address' do
        let(:billing_address) { nil }
        it { should redirect_to checkout_path }
      end

      context 'without a delivery address' do
        let(:delivery_address) { nil }
        it { should redirect_to checkout_path }
      end

      context 'with a shipping class' do
        let!(:shipping_class) { FactoryGirl.create(:shipping_class, name: 'Royal Mail') }
        before do
          allow(controller).to receive(:shipping_class).and_return(shipping_class)
          get :confirm
        end
        it 'records the shipping class name as the shipping method' do
          expect(Order.last.shipping_method).to eq 'Royal Mail'
        end
      end

      context 'without a shipping class' do
        before { get :confirm }
        it 'records "Standard Shipping" as the shipping method' do
          expect(Order.last.shipping_method).to eq 'Standard Shipping'
        end
      end

      context 'pending payments email setting' do
        before do
          website.send_pending_payment_emails = send_pending_payment_emails
          website.save
        end

        context 'when on' do
          let(:send_pending_payment_emails) { true }

          it 'sends an email to admin' do
            expect(OrderNotifier).to receive(:admin_waiting_for_payment).and_call_original
            get :confirm
          end
        end

        context 'when off' do
          let(:send_pending_payment_emails) { false }

          it 'does not send an email to admin' do
            expect(OrderNotifier).not_to receive(:admin_waiting_for_payment)
            get :confirm
          end
        end
      end

      it 'prepares payment methods' do
        expect(controller).to receive(:prepare_payment_methods)
        get :confirm
      end
    end
  end

  describe '#prepare_payment_methods' do
    context 'when Sage Pay is active' do
      before do
        allow(website).to receive(:sage_pay_active?).and_return(true)
        allow(website).to receive(:cardsave_active?).and_return(false)
      end

      let(:order) { FactoryGirl.create(:order) }

      it 'instantiates a SagePay' do
        allow(website).to receive(:sage_pay_pre_shared_key).and_return 'secret'

        expect(SagePay).to receive(:new).with(hash_including(
          pre_shared_key: website.sage_pay_pre_shared_key,
          vendor_tx_code: order.order_number,
          amount: order.total,
          delivery_surname: order.delivery_full_name,
          delivery_firstnames: order.delivery_full_name,
          delivery_address: order.delivery_address_line_1,
          delivery_city: order.delivery_town_city,
          delivery_post_code: order.delivery_postcode,
          delivery_country: order.delivery_country.iso_3166_1_alpha_2,
          success_url: sage_pay_success_payments_url,
          failure_url: sage_pay_failure_payments_url
        )).and_return(double(SagePay).as_null_object)
        controller.prepare_payment_methods(order)
      end

      it 'assigns @crypt from the SagePay' do
        allow(SagePay).to receive(:new).and_return(double(SagePay, encrypt: 'crypt'))
        controller.prepare_payment_methods(order)
        expect(assigns(:crypt)).to eq 'crypt'
      end
    end
  end

  def add_items_to_basket
    @basket = FactoryGirl.create(:basket)
    t_shirt = FactoryGirl.create(:product, weight: 0.2)
    jeans = FactoryGirl.create(:product, weight: 0.35)
    FactoryGirl.create(:basket_item, product: t_shirt, quantity: 2, basket_id: @basket.id)
    FactoryGirl.create(:basket_item, product: jeans, quantity: 1, basket_id: @basket.id)
    allow(controller).to receive(:basket).and_return(@basket)
  end
end
