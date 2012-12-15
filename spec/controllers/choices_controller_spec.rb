require 'spec_helper'

describe ChoicesController do
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

      it 'instantiates a new Choice' do
        Choice.should_receive(:new).and_return(mock_model(Choice).as_null_object)
        get 'new'
      end

      it 'assigns @choice' do
        choice = mock_model(Choice).as_null_object
        Choice.stub(:new).and_return(choice)
        get 'new'
        assigns(:choice).should == choice
      end

      it 'sets @choice.feature_id to the feature_id supplied as a parameter' do
        choice = Choice.new
        Choice.stub(:new).and_return(choice)
        get 'new', feature_id: 123
        choice.feature_id.should == 123
      end

      context 'when the feature is valid' do
        it "renders 'new'" do
          controller.stub(:feature_valid?).and_return(true)
          get 'new'
          response.should render_template('new')
        end
      end

      context 'when the feature is invalid' do
        it 'redirects to the products page' do
          controller.stub(:feature_valid?).and_return(false)
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
