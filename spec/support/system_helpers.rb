module SystemHelpers
  # Sets the session returned to controllers.
  def set_session(session)
    allow_any_instance_of(ApplicationController).to receive(:session).and_return(session)
  end

  # Signs in the session as an administrator and returns the administrator that
  # was created.
  def sign_in_as_admin
    admin = FactoryBot.create(:administrator)
    login_as(admin, scope: :administrator)
    admin
  end

  def sign_in_as_reporter
    reporter = FactoryBot.create(:administrator, reporter: true)
    login_as(reporter, scope: :administrator)
  end

  def sign_in_as_station
    station = FactoryBot.create(:station)
    login_as(station, scope: :station)
    station
  end

  def sign_in_as(user)
    visit "/customer_sessions/new"
    fill_in "email", with: user.email
    fill_in "password", with: user.password
    click_button "Sign In"
  end

  # Checks <tt>check_box</tt> when <tt>value</tt> is <tt>true</tt>, otherwise
  # unchecks it.
  def check_or_uncheck(check_box, value)
    value ? check(check_box) : uncheck(check_box)
  end
end
