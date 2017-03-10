require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  def mock_product(stubs={})
    @mock_product ||= double(Product, stubs)
  end

  describe "GET show" do
    context 'when product inactive' do
      before do
        find_requested_product(
          :active? => false, page_title: '', name: '', meta_description: ''
        )
      end

      context 'as admin' do
        before { logged_in_as_admin }

        it 'succeeds' do
          get :show, params: { id: '37' }
          expect(response).to be_successful
        end
      end

      context 'as visitor' do
        it '404s' do
          get :show, params: { id: '37' }
          expect(response.status).to eq 404
        end
      end
    end
  end

  def find_requested_product(stubs={})
    expect(Product).to receive(:find_by).with(id: '37').and_return(mock_product(stubs))
  end
end
