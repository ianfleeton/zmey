Then /^I should be redirected to (.+)$/ do |page_name|
#  request.headers['HTTP_REFERER'].should_not be_nil
#  request.headers['HTTP_REFERER'].should_not == request.request_uri
  response.redirected_to.should_not be_nil
  visit url_for response.redirected_to()
  Then "I should be on #{page_name}"
end
