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

  describe 'GET billing' do
    context 'with empty basket' do
      before { get :billing }
      it { should redirect_to basket_path }
    end

    context 'with items in the basket' do
      let(:addresses) { [] }
      let(:current_user) { User.new }
      let!(:uk) { FactoryGirl.create(:country, name: 'United Kingdom') }

      before do
        add_items_to_basket
        session[:name] = 'n'
        session[:phone] = '1'
        session[:email] = 'x'
        session[:billing_address_id] = billing_address_id
        allow_any_instance_of(User).to receive(:addresses).and_return addresses
        allow(controller).to receive(:current_user).and_return(current_user)
        get :billing
      end

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

          it { should set_session(:return_to).to('billing') }
          it { should redirect_to choose_billing_address_addresses_path }
        end

        context 'when user has no addresses' do
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
