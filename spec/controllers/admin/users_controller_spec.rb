require 'spec_helper'

describe Admin::UsersController do
  let(:website) { mock_model(Website).as_null_object }
  let(:user) { mock_model(User).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  context 'when admin or manager' do
    before { controller.stub(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      it 'assigns all users for the current website to @users' do
        website.should_receive(:users).and_return :some_users
        get 'index'
        assigns(:users).should eq :some_users
      end
    end

    describe 'PATCH update' do
      def patch_valid
        patch 'update', id: '1', user: {'some' => 'params'}
      end

      it 'finds the user' do
        User.should_receive(:find).with('1').and_return(user)
        patch_valid
      end

      it 'sets @user' do
        User.stub(:find).with('1').and_return(user)
        patch_valid
        expect(assigns(:user)).to eq user
      end

      context 'when the user is found' do
        before { User.stub(:find).with('1').and_return(user) }

        it 'updates the user' do
          user.should_receive(:update_attributes)
          patch_valid
        end

        context 'when the update succeeds' do
          before { user.stub(:update_attributes).and_return(true) }

          it 'redirects to the admin show user path' do
            patch_valid
            expect(response).to redirect_to(admin_user_path(user))
          end
        end
      end
    end
  end
end
