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

  describe 'GET index' do
    before { allow(controller).to receive(:logged_in?).and_return(logged_in) }
    let(:logged_in) { true }
    let(:source) { nil }

    it_behaves_like 'an address book', :get, :index

    context do
      before { get :index, source: source }

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

  describe 'GET new' do
    it 'assigns a new Address to @address' do
      allow(Address).to receive(:new).and_return(mock_address)
      get 'new'
      expect(assigns(:address)).to eq mock_address
    end
  end

  describe 'GET edit' do
    context 'with an address ID stored in session' do
      before { session[:address_id] = 2 }

      it 'finds the address from the stored ID' do
        expect(Address).to receive(:find_by).with(id: 2)
        get 'edit', id: '1'
      end

      context 'when found' do
        before { allow(Address).to receive(:find_by).and_return(mock_address) }

        it 'renders edit' do
          get 'edit', id: '1'
          expect(response).to render_template('edit')
        end
      end

      context 'when not found' do
        before { allow(Address).to receive(:find_by).and_return(nil) }

        it 'redirects to new' do
          get 'edit', id: '1'
          expect(response).to redirect_to(new_address_path)
        end
      end
    end

    context 'without an address ID stored in session' do
      it 'redirects to new' do
        get 'edit', id: '1'
        expect(response).to redirect_to(new_address_path)
      end
    end
  end
end
