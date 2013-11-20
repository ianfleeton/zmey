Given /^I am logged in as an administrator$/ do
  @current_user = User.create!(
    email: 'admin@example.org',
    name: 'Admin',
    password: 'admin',
    forgot_password_token: ''
  ) { |u| u.admin = true
          u.manages_website_id = 1
          u.website_id = 1}

  step "I am on the login page"
  fill_in("Email", with: @current_user.email)
  fill_in("Password", with: @current_user.password)
  click_button(I18n.t('login'))
end

Then /^I should see a list of websites$/ do
  step "I should see \"#{websites(:guitar_gear).name}\""
  step "I should see \"#{websites(:website_without_analytics).name}\""
end

Then /^I should see links to edit websites$/ do
  # check one of the websites
  page.should have_xpath("//a[@href='#{edit_website_path(websites(:guitar_gear))}']")
end

Then /^I should see a link to add a new website$/ do
  page.should have_xpath("//a[@href='#{new_website_path}']")
end

Then /^a new website should exist with the domain "([^\"]*)"$/ do |domain|
  Website.find_by(domain: domain).should_not be_nil
end

