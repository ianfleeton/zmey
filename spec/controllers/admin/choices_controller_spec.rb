require 'spec_helper'

describe Admin::ChoicesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    controller.stub(:website).and_return(website)
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
        expect(assigns(:choice)).to eq choice
      end

      it 'sets @choice.feature_id to the feature_id supplied as a parameter' do
        choice = Choice.new
        Choice.stub(:new).and_return(choice)
        get 'new', feature_id: 123
        expect(choice.feature_id).to eq 123
      end

      context 'when the feature is valid' do
        it "renders 'new'" do
          controller.stub(:feature_valid?).and_return(true)
          get 'new'
          expect(response).to render_template('new')
        end
      end

      context 'when the feature is invalid' do
        it 'redirects to the products page' do
          controller.stub(:feature_valid?).and_return(false)
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
end
