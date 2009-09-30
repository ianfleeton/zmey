Given /^a website where users cannot create accounts$/ do
  @host = websites(:website_without_analytics).domain
end

Given /^a website where users can create accounts$/ do
  @host = websites(:guitar_gear).domain
end
