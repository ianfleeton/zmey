# Increase from the default of 2 seconds.
Capybara.default_max_wait_time = 5

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
    viewport: {width: 1280, height: 1280}
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :playwright
  end
end
