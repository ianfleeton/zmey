# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomerSessionsController, type: :controller do
  let(:email_verified_at) { Time.current }
  let(:encrypted_password) { "topsecret" }
  let(:account_created_at) { Time.current }
  let(:customer) do
    u = FactoryBot.create(
      :user,
      name: "Alice", email: "alice@example.com",
      email_verified_at: email_verified_at, created_at: account_created_at
    )
    u.update_column(:encrypted_password, encrypted_password)
    u
  end

  describe "POST #create" do
    it "authenticates the user" do
      expect(User).to receive(:authenticate)
      post "create"
    end

    context "when the user authenticates" do
      before do
        allow(User).to receive(:authenticate).and_return(customer)
      end

      it "preserves their basket" do
        basket = Basket.create!
        session[:basket_id] = basket.id
        post :create
        expect(session[:basket_id]).to eq basket.id
      end

      it "preserves other details" do
        session[:delivery_postcode] = "DN1 2QP"
        post :create
        expect(session[:delivery_postcode]).to eq "DN1 2QP"
      end

      context "email is verified" do
        it "sets the user ID in the session" do
          post :create
          expect(session[:user_id]).to eq customer.id
        end

        it "resets unverified_user_id, name and email in session" do
          session[:email] = "bob@example.org"
          session[:name] = "Bob"
          session[:unverified_user_id] = 123

          post :create

          expect(session[:email]).to eq "alice@example.com"
          expect(session[:name]).to eq "Alice"
          expect(session[:unverified_user_id]).to be_nil
        end

        context "when unsafe_redirect_url is present" do
          it "redirects to a safe version of the URL" do
            post(
              :create,
              params: {unsafe_redirect_url: "https://dodgy/path?dodgy=1"}
            )
            expect(response).to redirect_to "/path"
          end
        end

        context "when unsafe_redirect_url is missing" do
          it "redirects to the customer's account page" do
            post :create
            expect(response).to redirect_to(account_path)
          end
        end
      end

      context "email is unverified" do
        let(:email_verified_at) { nil }

        it "leaves the user ID in the session is unchanged" do
          post :create, session: {user_id: 0}
          expect(session[:user_id]).to eq 0
        end

        it "sets session[:unverified_user_id]" do
          post :create
          expect(session[:unverified_user_id]).to eq customer.id
        end

        it "redirects to email verification resend page" do
          post :create
          expect(response).to redirect_to account_verify_email_new_path
        end
      end
    end

    context "when authentication fails" do
      before do
        allow(User).to receive(:authenticate).and_return(nil)
      end

      context "redirection" do
        let(:redir_url) { nil }
        before do
          post(
            :create,
            params: {email: customer.email, unsafe_redirect_url: redir_url},
            session: {source: source}
          )
        end
        subject { response }

        context "when customer account has its password unset" do
          let(:source) { nil }
          let(:encrypted_password) { "unset" }

          context "when created before 19th August 2016" do
            let(:account_created_at) { Date.new(2016, 8, 18).in_time_zone }
            it do
              should redirect_to password_reset_customer_sessions_path(
                email: customer.email
              )
            end
          end

          context "when created on or after 19th August 2016" do
            let(:account_created_at) { Date.new(2016, 8, 19).in_time_zone }
            it do
              should redirect_to password_set_customer_sessions_path(
                email: customer.email
              )
            end
          end
        end

        context "when session[:source] is checkout/details" do
          let(:source) { "checkout/details" }
          it { should redirect_to checkout_details_path }
        end

        context "when session[:source] is anything else" do
          let(:source) { nil }
          it { should redirect_to new_customer_session_path }

          context "when unsafe_redirect_url set" do
            let(:redir_url) { "https://example.com/path" }
            it do
              path = new_customer_session_path(
                unsafe_redirect_url: "https://example.com/path"
              )
              should redirect_to path
            end
          end
        end
      end
    end
  end

  describe "POST #destroy" do
    it "redirects to sessions#new" do
      post "destroy"
      expect(response).to redirect_to(action: "new")
    end

    context "with redirect_to set" do
      it "redirects to the given uri" do
        post "destroy", params: {redirect_to: "/"}
        expect(response).to redirect_to("/")
      end
    end
  end
end
