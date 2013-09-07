require 'spec_helper'

describe AddressesController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_address(stubs={})
    @mock_address ||= mock_model(Address, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'GET new' do
    it 'assigns a new Address to @address' do
      Address.stub(:new).and_return(mock_address)
      get 'new'
      expect(assigns(:address)).to eq mock_address
    end
  end

  describe 'GET edit' do
    context 'with an address ID stored in session' do
      before { session[:address_id] = 2 }

      it 'finds the address from the stored ID' do
        Address.should_receive(:find_by).with(id: 2)
        get 'edit', id: '1'
      end

      context 'when found' do
        before { Address.stub(:find_by).and_return(mock_address) }

        it 'renders edit' do
          get 'edit', id: '1'
          expect(response).to render_template('edit')
        end
      end

      context 'when not found' do
        before { Address.stub(:find_by).and_return(nil) }

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
