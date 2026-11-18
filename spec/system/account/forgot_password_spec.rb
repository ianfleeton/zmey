require "rails_helper"

RSpec.describe "Forgot password", type: :system do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:existing_user) { FactoryBot.create(:user, email: "exists@example.org") }

  before do
    FactoryBot.create(:website)
    ActionMailer::Base.deliveries.clear
  end

  def request_reset(email)
    visit sign_in_path
    click_link I18n.t("account.sign_in_register.get_a_new_password")
    fill_in "Email", with: email
    perform_enqueued_jobs { click_button "Send" }
  end

  def reset_path_from_email
    url = ActionMailer::Base.deliveries.last.body.encoded[%r{https?://\S+}]
    URI(url).request_uri
  end

  scenario "Forget and reset password" do
    request_reset(existing_user.email)
    visit reset_path_from_email
    fill_in "Password", with: "a new password"
    click_button "Change"
    expect(User.authenticate_by(email: existing_user.email, password: "a new password"))
      .to eq existing_user
  end

  scenario "Reset link only works once" do
    request_reset(existing_user.email)
    path = reset_path_from_email
    visit path
    fill_in "Password", with: "a new password"
    click_button "Change"

    visit path
    expect(page).to have_content I18n.t("controllers.account.forgot_password.invalid_link")
  end

  scenario "Reset link expires after an hour" do
    request_reset(existing_user.email)
    path = reset_path_from_email
    travel 61.minutes do
      visit path
      expect(page).to have_content I18n.t("controllers.account.forgot_password.invalid_link")
    end
  end

  scenario "Password too short" do
    request_reset(existing_user.email)
    visit reset_path_from_email
    fill_in "Password", with: "short"
    click_button "Change"
    expect(page).to have_content "Password is too short"
  end

  scenario "Unknown email address gets the same response and no email" do
    request_reset("nobody@example.org")
    expect(page).to have_content "If an account exists for that email address"
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  scenario "Repeat requests within a few minutes send only one email" do
    request_reset(existing_user.email)
    request_reset(existing_user.email)
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end
end
