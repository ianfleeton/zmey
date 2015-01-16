require 'rails_helper'

describe AddressesController do
  let(:website) { FactoryGirl.build(:website) }

  def mock_address(stubs={})
    @mock_address ||= double(Address, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  shared_examples_for 'an address book' do |method, action|
    let(:current_user) { FactoryGirl.create(:user) }

    before do
      FactoryGirl.create(:address, user_id: current_user.id)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it "assigns the current user's addresses to @addresses" do
      send(method, action)
      expect(assigns(:addresses)).to eq current_user.reload.addresses
    end
  end

  shared_examples_for 'an authenticated action' do
    context 'when not signed in' do
      let(:logged_in) { false }
      it { should redirect_to sign_in_path }
    end
  end

  describe 'GET index' do
    let(:logged_in) { true }
    let(:source) { nil }

    before { allow(controller).to receive(:logged_in?).and_return(logged_in) }

    it_behaves_like 'an address book', :get, :index

    context do
      before { get :index, source: source }

      it_behaves_like 'an authenticated action'

      context 'when recognised source in param' do
        let(:source) { 'bad' }
        it { should set_session(:source).to 'address_book' }
      end

      context 'when recognised source in param' do
        let(:source) { 'billing' }
        it { should set_session(:source).to 'billing' }
      end

      context 'when not signed in' do
        let(:logged_in) { false }
        it { should redirect_to sign_in_path }
      end
    end
  end

  describe 'GET choose_billing_address' do
    let(:logged_in) { true }

    before { allow(controller).to receive(:logged_in?).and_return(logged_in) }

    it_behaves_like 'an address book', :get, :choose_billing_address

    context do
      before { get :choose_billing_address }
      it_behaves_like 'an authenticated action'
    end
  end

  describe 'GET choose_delivery_address' do
    let(:logged_in) { true }

    before { allow(controller).to receive(:logged_in?).and_return(logged_in) }

    it_behaves_like 'an address book', :get, :choose_delivery_address

    context do
      before { get :choose_delivery_address }
      it_behaves_like 'an authenticated action'
    end
  end

  describe 'POST select_for_billing' do
    let(:logged_in) { true }
    let(:address) { FactoryGirl.create(:address) }

    before do
      allow(controller).to receive(:logged_in?).and_return(logged_in)
      post :select_for_billing, id: address.id
    end

    it { should redirect_to checkout_path }
    it { should set_session(:billing_address_id).to address.id }
    it_behaves_like 'an authenticated action'
  end

  describe 'POST select_for_delivery' do
    let(:logged_in) { true }
    let(:address) { FactoryGirl.create(:address) }

    before do
      allow(controller).to receive(:logged_in?).and_return(logged_in)
      post :select_for_delivery, id: address.id
    end

    it { should redirect_to checkout_path }
    it { should set_session(:delivery_address_id).to address.id }
    it_behaves_like 'an authenticated action'
  end

  describe 'GET new' do
    let(:logged_in) { true }

    before do
      allow(controller).to receive(:logged_in?).and_return(logged_in)
      allow(Address).to receive(:new).and_return(mock_address)
      get :new
    end

    it 'assigns a new Address to @address' do
      expect(assigns(:address)).to eq mock_address
    end

    it_behaves_like 'an authenticated action'
  end

  describe 'GET edit' do
    let(:logged_in) { true }

    before do
      allow(controller).to receive(:logged_in?).and_return(logged_in)
      get :edit, id: '1'
    end

    context 'when address not found' do
      it 'redirects to new' do
        expect(response).to redirect_to(new_address_path)
      end
    end

    it_behaves_like 'an authenticated action'
  end
end
