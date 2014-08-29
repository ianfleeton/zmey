require 'rails_helper'

describe AddressesController do
  let(:website) { FactoryGirl.build(:website) }

  def mock_address(stubs={})
    @mock_address ||= double(Address, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
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
