require "rails_helper"

RSpec.describe "Rate limiting of forms", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before { FactoryBot.create(:website) }

  describe "customer sign in" do
    def attempt(email, ip: "203.0.113.1")
      # customer_sessions_path names the sign out route.
      post "/customer_sessions",
        params: {email: email, password: "wrong"},
        headers: {"REMOTE_ADDR" => ip}
    end

    it "blocks an IP address after 10 attempts" do
      10.times { |i| attempt("user#{i}@example.com") }
      expect(flash[:notice]).not_to eq I18n.t("rate_limited")

      attempt("another@example.com")
      expect(flash[:notice]).to eq I18n.t("rate_limited")
    end

    it "blocks an email address after 10 attempts from different IPs" do
      10.times { |i| attempt("target@example.com", ip: "203.0.113.#{i + 1}") }
      attempt("Target@Example.com ", ip: "198.51.100.1")
      expect(flash[:notice]).to eq I18n.t("rate_limited")
    end

    it "allows attempts again later" do
      11.times { attempt("target@example.com") }
      travel 6.minutes do
        attempt("target@example.com")
        expect(flash[:notice]).not_to eq I18n.t("rate_limited")
      end
    end
  end

  describe "administrator sign in" do
    it "blocks repeated attempts for an email address" do
      admin = FactoryBot.create(:administrator)
      11.times do |i|
        post administrator_session_path,
          params: {administrator: {email: admin.email, password: "wrong"}},
          headers: {"REMOTE_ADDR" => "203.0.113.#{i + 1}"}
      end
      expect(flash[:notice]).to eq I18n.t("rate_limited")
    end
  end

  describe "forgot password" do
    it "blocks an IP address after 5 requests" do
      6.times { post account_forgot_password_send_email_path, params: {email: "a@example.com"} }
      expect(flash[:notice]).to eq I18n.t("rate_limited")
    end
  end
end
