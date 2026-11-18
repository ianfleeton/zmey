require "rails_helper"

RSpec.describe "Communication preferences", type: :request do
  let(:user) { FactoryBot.create(:user, email: "user@a.com", opt_in: false) }
  let(:token) { user.generate_token_for(:communication_preferences) }

  describe "GET /account/communication_preferences/unsubscribe" do
    it "renders a form pointing to action: update for a valid token" do
      get account_communication_preferences_unsubscribe_path(token: token)
      assert_select(
        "form[action='#{account_communication_preferences_update_path}']"
      )
      expect(response.body).to include("user@a.com")
    end

    it "shows an invalid link page without a valid token" do
      get account_communication_preferences_unsubscribe_path(token: "forged")
      expect(response).to have_http_status(:not_found)
      assert_select "form", count: 0
    end

    it "rejects a token issued before the email address changed" do
      old_token = token
      user.update!(email: "new@a.com")
      get account_communication_preferences_path(token: old_token)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /account/communication_preferences/update" do
    def perform(wanted:, token: self.token)
      post account_communication_preferences_update_path,
        params: {token: token, wanted: wanted}
    end

    it "opts in and redirects to the updated screen" do
      perform(wanted: "Yes Please")
      expect(user.reload.opt_in).to be true
      expect(user.explicit_opt_in_at).to be_present
      expect(response).to redirect_to(account_communication_preferences_updated_path)
    end

    it "opts out" do
      user.update!(opt_in: true)
      perform(wanted: "No Thanks")
      expect(user.reload.opt_in).to be false
    end

    it "does not change anything given only an email address" do
      post account_communication_preferences_update_path,
        params: {email: user.email, wanted: "Yes Please"}
      expect(response).to have_http_status(:not_found)
      expect(user.reload.opt_in).to be false
    end
  end

  context "when signed in without a token" do
    before do
      allow_any_instance_of(Account::CommunicationPreferencesController)
        .to receive(:current_user).and_return(user)
    end

    it "redirects to account details" do
      get account_communication_preferences_path
      expect(response).to redirect_to(account_edit_path)
    end
  end
end
