module ControllerHelpers
  def logged_in_as_admin
    sign_in FactoryBot.create(:administrator), scope: :administrator
  end
end
