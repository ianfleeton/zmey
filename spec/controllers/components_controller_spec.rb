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
        assigns(:component).should == component
      end

      it 'sets @component.product_id to the product_id supplied as a parameter' do
        component = Component.new
        Component.stub(:new).and_return(component)
        get 'new', product_id: 123
        component.product_id.should == 123
      end

      context 'when the product is valid' do
        it "renders 'new'" do
          controller.stub(:product_valid?).and_return(true)
          get 'new'
          response.should render_template('new')
        end
      end

      context 'when the product is invalid' do
        it 'redirects to the products page' do
          controller.stub(:product_valid?).and_return(false)
          get 'new'
          response.should redirect_to(products_path)
        end
      end
    end

    context 'when not logged in as an administrator' do
      it 'redirects to the sign in page' do
        get 'new'
        response.should redirect_to(new_session_path)
      end
    end
  end
end
