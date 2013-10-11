require 'spec_helper'

describe ComponentsController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'GET new' do
    context 'when logged in as an administrator' do
      before do
        controller.stub(:admin?).and_return(true)
      end

      it 'instantiates a new Component' do
        Component.should_receive(:new).and_return(mock_model(Component).as_null_object)
        get 'new'
      end

      it 'assigns @component' do
        component = mock_model(Component).as_null_object
        Component.stub(:new).and_return(component)
        get 'new'
        expect(assigns(:component)).to eq component
      end

      it 'sets @component.product_id to the product_id supplied as a parameter' do
        component = Component.new
        Component.stub(:new).and_return(component)
        get 'new', product_id: 123
        expect(component.product_id).to eq 123
      end

      context 'when the product is valid' do
        it "renders 'new'" do
          controller.stub(:product_valid?).and_return(true)
          get 'new'
          expect(response).to render_template('new')
        end
      end

      context 'when the product is invalid' do
        it 'redirects to the products page' do
          controller.stub(:product_valid?).and_return(false)
          get 'new'
          expect(response).to redirect_to(products_path)
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

  shared_examples 'a component finder' do |method, action|
    let(:component) { FactoryGirl.create(:component) }

    context 'when product valid' do
      before do
        controller.stub(:admin?).and_return(true)
        component.product.website = website
        component.product.save
      end

      it 'finds and assigns the component to @component' do
        send(method, action, id: component.id, component: component.attributes)
        expect(assigns(:component)).to eq component
      end
    end
  end

  describe 'DELETE destroy' do
    it_behaves_like 'a component finder', :delete, :destroy

    let(:component) { FactoryGirl.create(:component) }

    before do
      controller.stub(:admin?).and_return(true)
      controller.stub(:product_valid?).and_return(true)
    end

    def delete_destroy
      delete :destroy, id: component.id
    end

    it 'destroys the component' do
      delete_destroy
      expect(Component.find_by(id: component.id)).to be_nil
    end

    it "redirects to the component's product editing page" do
      delete_destroy
      expect(response).to redirect_to edit_product_path(component.product)
    end

    it 'sets a flash notice' do
      delete_destroy
      expect(flash[:notice]).to eq I18n.t('components.destroy.deleted')
    end
  end
end
