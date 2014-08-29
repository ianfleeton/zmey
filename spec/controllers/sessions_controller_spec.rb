require 'rails_helper'

describe SessionsController do
  let(:website) { FactoryGirl.build(:website) }
  let(:customer) { FactoryGirl.create(:user, admin: false) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'POST #create' do
    it 'authenticates the user' do
      expect(User).to receive(:authenticate)
      post 'create'
    end

    context 'when the user authenticates as a customer' do
      before do
        allow(User).to receive(:authenticate).and_return(customer)
      end

      it "redirects to the customer's account page" do
        post 'create'
        expect(response).to redirect_to(customer)
      end
    end

    context 'when the user authenticates as an admin or manager' do
      before do
        allow(User).to receive(:authenticate).and_return(User.new)
        allow(controller).to receive(:admin_or_manager?).and_return(true)
      end

      it 'redirects to the admin page' do
        post 'create'
        expect(response).to redirect_to(admin_path)
      end
    end
  end
end
