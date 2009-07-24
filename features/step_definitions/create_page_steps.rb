Then /^a new page should exist with the slug "([^\"]*)"$/ do |slug|
  Page.find_by_slug(slug).should_not be_nil
end
