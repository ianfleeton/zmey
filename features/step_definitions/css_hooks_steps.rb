Then /^I should see a "([^"]*)" tag with a class of "([^"]*)"$/ do |arg1, arg2|
  response.should have_xpath("//#{arg1}[@class='#{arg2}']")
end
