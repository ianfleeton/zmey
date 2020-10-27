require "rails_helper"

RSpec.describe "Forgot password", type: :system do
  let(:existing_user) { FactoryBot.create(:user, email: "exists@example.org") }

  before { FactoryBot.create(:website) }

  scenario "Forget and reset password" do
    visit sign_in_path
    click_link I18n.t("account.sign_in_register.get_a_new_password")
    fill_in "Email", with: existing_user.email
    click_button "Send"
    existing_user.reload
    visit password_reset_path(existing_user)
    fill_in "Password", with: "a new password"
    expect {
      click_button "Change"
      existing_user.reload
    }.to(change { existing_user.encrypted_password })
  end

  def password_reset_path(user)
    "/account/forgot_password/new?id=#{user.id}&t=#{user.forgot_password_token}"
  end
end
