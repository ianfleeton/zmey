Given /^a website without tracking code$/ do
  @host = websites(:website_without_analytics).domain
end

Given /^a website with tracking code$/ do
  @host = websites(:guitar_gear).domain
end

Then /^I should find the correct tracking code$/ do
  response.should contain(websites(:guitar_gear).google_analytics_code)
end

Then /^I should not find tracking code$/ do
  response.should_not contain('google-analytics.com')
end