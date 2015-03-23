require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::UsersController do
  let(:website) { FactoryGirl.build(:website) }
  let(:user)    { FactoryGirl.create(:user) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  context 'when admin or manager' do
    before { allow(controller).to receive(:admin_or_manager?).and_return(true) }

    describe 'GET index' do
      it 'assigns users ordered by name to @users' do
        u1 = FactoryGirl.create(:user, name: 'User Z')
        u2 = FactoryGirl.create(:user, name: 'User A')
        get :index
        expect(assigns(:users).first).to eq u2
        expect(assigns(:users).last).to eq u1
      end
    end

    describe 'POST create' do
      def post_valid
        post 'create', user: {'some' => 'params'}
      end

      context 'when create succeeds' do
        before { allow_any_instance_of(User).to receive(:save).and_return(true) }

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
        expect(User).to receive(:find).with('1').and_return(user)
        patch_valid
      end

      it 'sets @user' do
        allow(User).to receive(:find).with('1').and_return(user)
        patch_valid
        expect(assigns(:user)).to eq user
      end

      context 'when the user is found' do
        before { allow(User).to receive(:find).with('1').and_return(user) }

        it 'updates the user' do
          expect(user).to receive(:update_attributes)
          patch_valid
        end

        context 'when the update succeeds' do
          before { allow(user).to receive(:update_attributes).and_return(true) }

          it 'redirects to the admin show user path' do
            patch_valid
            expect(response).to redirect_to(admin_user_path(user))
          end
        end
      end
    end
  end
end
