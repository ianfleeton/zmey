require 'spec_helper'

describe ProductPlacementsController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'POST create' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = mock_model(Page)
        pp = mock_model(ProductPlacement, page: page, save: true)
        ProductPlacement.stub(:new).and_return(pp)
        post 'create', { 'product_placement' => {'some' => 'params'} }
        expect(response).to redirect_to(edit_page_path(page))
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = mock_model(Page)
        pp = mock_model(ProductPlacement, page: page)
        ProductPlacement.stub(:find).and_return(pp)
        delete 'destroy', id: '1'
        expect(response).to redirect_to(edit_page_path(page))
      end
    end
  end

  describe 'POST move_up' do
    context 'when logged in as admin' do
      before { logged_in_as_admin }

      it 'redirects to the page edit page' do
        page = mock_model(Page)
        pp = mock_model(ProductPlacement, page: page, move_higher: true)
        ProductPlacement.stub(:find).and_return(pp)
        post 'move_up'
        expect(response).to redirect_to(edit_page_path(page))
      end
    end
  end

  def logged_in_as_admin
    controller.stub(:admin?).and_return(true)
  end
end
