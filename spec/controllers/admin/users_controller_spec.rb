require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  context "when admin or manager" do
    before { allow(controller).to receive(:admin?).and_return(true) }

    describe "POST create" do
      def post_valid
        post "create", params: {user: {"some" => "params"}}
      end

      context "when create succeeds" do
        before { allow_any_instance_of(User).to receive(:save).and_return(true) }

        it "sets a flash notice" do
          post_valid
          expect(flash[:notice]).to eq I18n.t("controllers.admin.users.create.flash.created")
        end

        it "redirects to the admin users path" do
          post_valid
          expect(response).to redirect_to admin_users_path
        end
      end
    end

    describe "PATCH update" do
      def patch_valid
        patch "update", params: {id: "1", user: {"some" => "params"}}
      end

      context "when the user is found" do
        before { allow(User).to receive(:find).with("1").and_return(user) }

        it "updates the user" do
          expect(user).to receive(:update)
          patch_valid
        end

        context "when the update succeeds" do
          before { allow(user).to receive(:update).and_return(true) }

          it "redirects to the admin show user path" do
            patch_valid
            expect(response).to redirect_to(admin_user_path(user))
          end
        end
      end
    end
  end
end
