require "rails_helper"

RSpec.describe "Communication preferences", type: :request do
  describe "GET /account/communication_preferences/unsubscribe" do
    it "renders a form pointing to action: update" do
      get account_communication_preferences_unsubscribe_path
      assert_select(
        "form[action='#{account_communication_preferences_update_path}']"
      )
    end
  end

  describe "POST /account/communication_preferences/update" do
    let(:wanted) { nil }
    before do
      allow(User)
        .to receive(:find_by).and_return(nil)
      allow(User)
        .to receive(:find_by).with(email: "user@a.com").and_return(user)
    end

    def perform
      post(
        account_communication_preferences_update_path(
          params: {email: "user@a.com", wanted: wanted}
        )
      )
    end

    context "when user is found" do
      let(:user) { instance_double(User, save: true) }

      it "saves the user" do
        allow(user).to receive(:update_explicit_opt_in)
        expect(user).to receive(:save)
        perform
      end

      it "sets redirects to the updated screen" do
        allow(user).to receive(:update_explicit_opt_in)
        perform
        expect(response).to redirect_to(
          account_communication_preferences_updated_path
        )
      end

      context "when user wants to opt in" do
        let(:wanted) { "Yes Please" }
        it "updates the explict opt-it" do
          expect(user).to receive(:update_explicit_opt_in).with(true)
          perform
        end
      end

      context "when user wants to opt out" do
        let(:wanted) { "No Thanks" }
        it "updates the explict opt-it" do
          expect(user).to receive(:update_explicit_opt_in).with(false)
          perform
        end
      end
    end

    context "when user not found" do
      before { perform }
      let(:user) { nil }
      it "redirects to index" do
        expect(response).to redirect_to(account_communication_preferences_path)
      end
      it "sets a flash notice" do
        expect(flash[:notice]).to eq I18n.t(
          "controllers.account.communication_preferences.update.unrecognised"
        )
      end
    end
  end
end
