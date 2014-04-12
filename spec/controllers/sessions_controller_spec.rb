require 'spec_helper'

describe SessionsController do
  let(:website) { FactoryGirl.build(:website) }
  let(:customer) { mock_model(User, admin?: false).as_null_object }

  before do
    controller.stub(:website).and_return(website)
  end

  describe 'POST #create' do
    it 'authenticates the user' do
      User.should_receive(:authenticate)
      post 'create'
    end

    context 'when the user authenticates as a customer' do
      before do
        User.stub(:authenticate).and_return(customer)
      end

      it "redirects to the customer's account page" do
        post 'create'
        expect(response).to redirect_to(customer)
      end
    end

    context 'when the user authenticates as an admin or manager' do
      before do
        User.stub(:authenticate).and_return(User.new)
        controller.stub(:admin_or_manager?).and_return(true)
      end

      it 'redirects to the admin page' do
        post 'create'
        expect(response).to redirect_to(admin_path)
      end
    end
  end
end
