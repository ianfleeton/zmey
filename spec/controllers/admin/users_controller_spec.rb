require 'spec_helper'
require 'shared_examples_for_controllers'

describe Admin::UsersController do
  let(:website) { FactoryGirl.build(:website) }
  let(:user) { mock_model(User).as_null_object }

  before do
    controller.stub(:website).and_return(website)
  end

  context 'when admin or manager' do
    before { controller.stub(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      it_behaves_like 'a website owned objects finder', :user
    end

    describe 'POST create' do
      it_behaves_like 'a website association creator', :user

      def post_valid
        post 'create', user: {'some' => 'params'}
      end

      context 'when create succeeds' do
        before { User.any_instance.stub(:save).and_return(true) }

        it 'sets a flash notice' do
          post_valid
          expect(flash[:notice]).to eq I18n.t('controllers.admin.users.create.flash.created')
        end

        it 'redirects to the admin users path' do
          post_valid
          expect(response).to redirect_to admin_users_path
        end
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
