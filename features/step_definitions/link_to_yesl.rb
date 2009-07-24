Then /^I should see a link to Your e Solutions$/ do
  response.should have_xpath("//a[@href='http://www.yesl.co.uk/']")
end
