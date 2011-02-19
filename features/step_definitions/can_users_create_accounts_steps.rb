Given /^a website where users cannot create accounts$/ do
  @website = websites(:guitar_gear)
  @website.can_users_create_accounts = false
  @website.save
end

Given /^a website where users can create accounts$/ do
  @website = websites(:guitar_gear)
  @website.can_users_create_accounts = true
  @website.save
end
