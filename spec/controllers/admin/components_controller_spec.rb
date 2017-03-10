require 'rails_helper'

RSpec.describe Admin::ComponentsController, type: :controller do
  describe 'GET new' do
    context 'when logged in as an administrator' do
      before do
        allow(controller).to receive(:admin?).and_return(true)
      end

      it 'instantiates a new Component' do
        allow(controller).to receive(:product_valid?)
        expect(Component).to receive(:new).and_return(double(Component).as_null_object)
        get 'new'
      end

      it 'sets @component.product_id to the product_id supplied as a parameter' do
        component = Component.new
        allow(Component).to receive(:new).and_return(component)
        get 'new', params: { product_id: 123 }
        expect(component.product_id).to eq 123
      end

      context 'when the product is invalid' do
        it 'redirects to the products page' do
          allow(controller).to receive(:product_valid?).and_return(false)
          get 'new'
          expect(response).to redirect_to(admin_products_path)
        end
      end
    end

    context 'when not logged in as an administrator' do
      it 'redirects to the sign in page' do
        get 'new'
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:component) { FactoryGirl.create(:component) }

    before do
      allow(controller).to receive(:admin?).and_return(true)
      allow(controller).to receive(:product_valid?).and_return(true)
    end

    def delete_destroy
      delete :destroy, params: { id: component.id }
    end

    it 'destroys the component' do
      delete_destroy
      expect(Component.find_by(id: component.id)).to be_nil
    end

    it "redirects to the component's product editing page" do
      delete_destroy
      expect(response).to redirect_to edit_admin_product_path(component.product)
    end

    it 'sets a flash notice' do
      delete_destroy
      expect(flash[:notice]).to eq I18n.t('components.destroy.deleted')
    end
  end
end
