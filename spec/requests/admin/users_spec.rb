require "rails_helper"

RSpec.describe "Users admin", type: :request do
  let(:user) { FactoryBot.create(:user) }

  context "when admin" do
    before do
      administrator = FactoryBot.create(:administrator)
      sign_in administrator
    end

    describe "POST /admin/users" do
      let(:params) { {user: {"some" => "params"}} }
      def post_valid
        post("/admin/users", params:)
      end

      context "with valid params" do
        let(:params) { {user: {"email" => "shopper@example.org", name: "Shopper", password: "topsecret", password_confirmation: "topsecret"}} }

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

    describe "PATCH /admin/users/:id" do
      let(:params) { {user: {"email" => "invalid"}} }
      let(:user) { FactoryBot.create(:user) }

      def perform
        patch("/admin/users/#{user.id}", params:)
      end

      context "with invalid params" do
        it "re-renders the edit user screen" do
          perform
          expect(response.body).to include("Edit User")
        end
      end

      context "with valid params" do
        let(:params) { {user: {"email" => "shopper@example.org", name: "Shopper", password: "topsecret", password_confirmation: "topsecret"}} }
        it "updates the user" do
          perform
        end

        context "when the update succeeds" do
          before { allow(user).to receive(:update).and_return(true) }

          it "redirects to the admin show user path" do
            perform
            expect(response).to redirect_to(admin_user_path(user))
          end
        end
      end
    end
  end
end
