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
      before { add_items_to_basket }

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

    context 'with authenticated user' do
      let(:current_user) { FactoryGirl.create(:user) }

      it 'associates address with the user' do
        expect(assigns(:address).user).to eq current_user
      end
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
      let(:current_user) { User.new }
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
        allow(controller).to receive(:current_user).and_return(current_user)
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

  describe 'POST save_billing' do
    let(:address) { FactoryGirl.build(:address, address_line_1: SecureRandom.hex) }
    let(:billing_address) { nil }

    before do
      allow(controller).to receive(:billing_address).and_return(billing_address)
      post :save_billing, address: address.attributes 
    end

    context 'when billing address found' do
      let(:billing_address) { FactoryGirl.create(:address) }

      it 'updates the billing address' do
        expect(billing_address.reload.address_line_1).to eq address.address_line_1
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
      it { should redirect_to delivery_details_path }
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
      let(:current_user) { User.new }
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
        allow(controller).to receive(:current_user).and_return(current_user)
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

  describe 'GET confirm' do
    context 'with empty basket' do
      before { get :confirm }

      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      before { add_items_to_basket }

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

  def add_items_to_basket
    basket = FactoryGirl.create(:basket)
    FactoryGirl.create(:basket_item, basket_id: basket.id)
    allow(controller).to receive(:basket).and_return(basket)
  end
end
