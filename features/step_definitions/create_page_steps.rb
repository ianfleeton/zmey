Then /^a new page should exist with the slug "([^\"]*)"$/ do |slug|
  Page.find_by(slug: slug).should_not be_nil
end
