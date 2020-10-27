# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account", type: :request do
  include ActiveJob::TestHelper

  describe "GET /account/new" do
    it "has a robots NOINDEX meta tag" do
      get account_new_path
      assert_select 'meta[name=robots][content="noindex, follow"]'
    end

    it "sets source in session to account/new" do
      get account_new_path
      expect(session[:source]).to eq "account/new"
    end

    context "when already signed in" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:logged_in?).and_return(true)
      end

      it "redirects to account" do
        get "/account/new"
        expect(response).to redirect_to account_path
      end
    end
  end

  describe "POST /account" do
    let(:user_params) do
      {
        email: "#{SecureRandom.hex}@example.org",
        name: "Customer",
        password: "secret123",
        password_confirmation: "secret123"
      }
    end
    let(:website) { FactoryBot.build_stubbed(:website) }
    let(:source) { nil }
    let(:unsafe_redirect_url) { nil }

    before do
      @session = {source: source}
      allow_any_instance_of(AccountController).to receive(:website)
        .and_return(website)
    end

    it "creates a new user" do
      expect { post_create }.to change { User.count }.by(1)
    end

    it "sets a flash notice" do
      post_create
      expect(flash[:notice]).to eq I18n.t("controllers.account.create.created")
    end

    it "sets unverified_user_id in the session" do
      post_create
      expect(@session[:unverified_user_id]).to eq User.last.id
    end

    it "does not set user_id in the session" do
      post_create
      expect(session[:user_id]).to be_nil
    end

    it "sends an email verfication email" do
      user = FactoryBot.build_stubbed(:user)
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:save).and_return(true)
      delivery = double(ActionMailer::MessageDelivery)
      expect(UserNotifier).to receive(:email_verification).with(website, user).and_return(delivery)
      expect(delivery).to receive(:deliver_later)
      post_create
    end

    context "source is unknown" do
      it "redirects user to home page" do
        post_create
        expect(response).to redirect_to root_path
      end

      context "when unsafe_redirect_url is set" do
        let(:unsafe_redirect_url) { "https://dodgy/path?dodgy=1" }
        it "redirects to a safe path" do
          post_create
          expect(response).to redirect_to "/path"
        end
      end
    end

    context "source is checkout/details" do
      let(:source) { "checkout/details" }
      it "redirects user back to checkout/details" do
        post_create
        expect(response).to redirect_to checkout_details_path
      end
    end

    def post_create
      allow_any_instance_of(AccountController).to receive(:session).and_return(@session)
      post(
        account_path,
        params: {user: user_params, unsafe_redirect_url: unsafe_redirect_url}
      )
    end
  end

  describe "GET /account/change_password" do
    let(:user) { FactoryBot.create(:user) }

    it "renders OK" do
      allow_any_instance_of(AccountController)
        .to receive(:current_user).and_return(user)
      get account_change_password_path, params: {id: user.id}
      expect(response.status).to eq 200
    end
  end

  describe "POST /account/update_password" do
    let(:user) { FactoryBot.create(:user, password: "oldpassword") }

    before do
      # Serializable website required to send delayed email.
      FactoryBot.create(:website)
    end

    context "new password set with matching confirmation" do
      before do
        allow_any_instance_of(AccountController)
          .to receive(:current_user).and_return(user)
      end

      def post_update_password
        post(
          account_update_password_path,
          params: {
            password: "newpassword", password_confirmation: "newpassword"
          }
        )
      end

      it "redirects to the account page" do
        post_update_password
        expect(response).to redirect_to account_path
      end

      it "updates the password" do
        post_update_password
        expect(User.authenticate(user.email, "newpassword")).to eq user
      end

      it "sends an email alerting the user that the password has changed" do
        ActionMailer::Base.deliveries = []

        post_update_password
        perform_enqueued_jobs
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.last.subject).to(
          include("your password has been changed")
        )
      end

      it "sets a flash notice" do
        post_update_password
        expect(flash[:notice]).to eq I18n.t("controllers.account.update_password.changed")
      end
    end

    context "new password set with matching confirmation, but too short" do
      before do
        allow_any_instance_of(AccountController)
          .to receive(:current_user).and_return(user)
        post(
          account_update_password_path,
          params: {id: user.id, password: "123", password_confirmation: "123"}
        )
      end

      it "renders the form again" do
        assert_select "form"
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq I18n.t("controllers.account.update_password.invalid")
      end
    end
  end

  describe "POST /account/set_unverified_password" do
    def stub_email
      allow(UserNotifier)
        .to receive(:email_verification)
        .and_return(
          instance_double(ActionMailer::MessageDelivery).as_null_object
        )
    end

    context "when user is unverified, no password set" do
      let(:user) do
        FactoryBot.create(:user, encrypted_password: User::UNSET, password: nil)
      end
      before do
        allow(User).to receive(:unverified_user).and_return(user)
      end

      context "when new password is fine" do
        def perform
          post(
            account_set_unverified_password_path,
            params: {password: "supersecret"}
          )
        end

        it "redirects back (default home page)" do
          stub_email
          perform
          expect(response).to redirect_to root_path
        end

        it "sets the user's password" do
          stub_email
          perform
          expect(User.authenticate(user.email, "supersecret")).to eq user
        end

        it "sets a flash notice" do
          stub_email
          perform
          expect(flash[:notice]).to be_present
        end

        it "sends an email" do
          expect(UserNotifier)
            .to receive(:email_verification)
            .and_return(
              instance_double(ActionMailer::MessageDelivery).as_null_object
            )
          perform
        end
      end

      context "when password is invalid (e.g., too short)" do
        def perform
          post account_set_unverified_password_path, params: {password: "short"}
        end

        it "sets a flash alert" do
          perform
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe "GET /account/verify_email" do
    let(:user) { FactoryBot.create(:user) }
    let(:id) { user.id }
    let(:t) { user.email_verification_token }
    let(:source) { nil }

    context "with valid details" do
      before do
        @session = {source: source}
        allow_any_instance_of(AccountController)
          .to receive(:session).and_return(@session)
        get account_verify_email_path, params: {id: id, t: t}
      end

      it "should set the email_verified_at timestamp and saves the user" do
        expect(user.reload.email_verified_at).to be
      end

      it "signs the customer in" do
        expect(@session[:user_id]).to eq user.id
      end

      it "sets a flash notice" do
        expect(flash[:notice])
          .to eq I18n.t("controllers.account.verify_email.verified")
      end

      context "session[:source] is set to checkout/details" do
        let(:source) { "checkout/details" }
        it "redirects the customer to checkout/details" do
          expect(response).to redirect_to checkout_details_path
        end
      end

      context "session[:source] is not checkout/details" do
        it "redirects to the home page" do
          expect(response).to redirect_to root_path
        end
      end
    end

    shared_examples_for "an invalid details handler" do
      before do
        allow_any_instance_of(AccountController)
          .to receive(:session).and_return(source: source)
        get account_verify_email_path, params: {id: id, t: t}
      end

      it "redirects to a form to send a new verification email" do
        expect(response).to redirect_to account_verify_email_new_path
      end

      it "sets a notice" do
        expect(flash[:notice])
          .to eq I18n.t("controllers.account.verify_email.invalid_link")
      end
    end

    context "with invalid user ID" do
      let(:id) { -1 }

      it_behaves_like "an invalid details handler"
    end

    context "with invalid token" do
      let(:t) { "ALLWRONG" }

      it_behaves_like "an invalid details handler"
    end
  end

  describe "GET verify_email_new" do
    it "responds 200 OK" do
      get account_verify_email_new_path
      expect(response).to have_http_status(:ok)
    end

    it "has a form to enter email address" do
      get account_verify_email_new_path
      assert_select "form[action='#{account_verify_email_send_path}']" do
        assert_select "input#verify_email[type='email'][name='email']"
        assert_select "input[type=submit][value='Send']"
      end
    end

    context "unverified user in session" do
      let(:unverified_user) { FactoryBot.create(:user) }

      before do
        allow_any_instance_of(AccountController)
          .to receive(:session).and_return(unverified_user_id: unverified_user.id)
        get account_verify_email_new_path
      end

      it "prefills the email address" do
        assert_select "input#verify_email[value='#{unverified_user.email}']"
      end
    end
  end

  describe "POST verify_email_send" do
    context "unverified user recognised" do
      let(:token) { "token" }
      let(:unverified_user) do
        u = FactoryBot.create(:user, email_verification_token: token)
        u.update_attribute(:email_verification_token, token)
        u
      end

      before do
        allow_any_instance_of(AccountController)
          .to receive(:website)
          .and_return(FactoryBot.create(:website))
        post account_verify_email_send_path, params: {email: unverified_user.email}
      end

      it "sets session[:unverified_user_id]" do
        expect(session[:unverified_user_id]).to eq unverified_user.id
      end

      it "sends an email verfication email" do
        user = instance_double(
          User,
          save: true, id: 123, email_verified_at: Time.current,
          email_verification_token: token, persisted?: true
        )
        allow(User).to receive(:find_by).and_return(user)
        website = Website.new
        allow_any_instance_of(AccountController)
          .to receive(:website).and_return(website)
        delivery = double(ActionMailer::MessageDelivery)
        expect(UserNotifier).to receive(:email_verification).with(website, user).and_return(delivery)
        expect(delivery).to receive(:deliver_later)
        post(
          account_verify_email_send_path,
          params: {email: unverified_user.email}
        )
      end

      it "redirects to verify_email_new" do
        expect(response).to redirect_to account_verify_email_new_path
      end

      it "sets a flash notice" do
        expect(flash[:notice])
          .to eq I18n.t("controllers.account.verify_email_send.sent")
      end

      context "when user has a verification token" do
        it "leaves the token alone" do
          expect(unverified_user.reload.email_verification_token).to eq "token"
        end
      end

      context "when user has no verification token" do
        let(:token) { nil }
        it "sets a new token" do
          expect(unverified_user.reload.email_verification_token).to be
        end
      end
    end

    context "unverified user not recognised" do
      before do
        post(
          account_verify_email_send_path,
          params: {email: "unrecognised@example.com"}
        )
      end

      it "redirects to account/new" do
        expect(response).to redirect_to account_new_path
      end

      it "sets a flash notice" do
        expect(flash[:notice])
          .to eq I18n.t("controllers.account.verify_email_send.unrecognised")
      end
    end
  end
end
