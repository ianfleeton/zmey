require 'rails_helper'

describe Admin::ProductPlacementsController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'POST create' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = double(Page)
        pp = double(ProductPlacement, page: page, save: true)
        allow(ProductPlacement).to receive(:new).and_return(pp)
        post 'create', { 'product_placement' => {'some' => 'params'} }
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = double(Page)
        pp = double(ProductPlacement, page: page, destroy: nil)
        allow(ProductPlacement).to receive(:find).and_return(pp)
        delete 'destroy', id: '1'
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end

  describe 'POST move_up' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = double(Page)
        pp = double(ProductPlacement, page: page, move_higher: true)
        allow(ProductPlacement).to receive(:find).and_return(pp)
        post 'move_up', id: '1'
        expect(response).to redirect_to(edit_admin_page_path(page))
      end
    end
  end
end
