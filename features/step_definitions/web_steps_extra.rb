Given /^(?:|I )am on (.+)$/ do |page_name|
  header 'Host', (@host.nil? ? 'www.guitar-gear.com' : @host)
  visit path_to(page_name)
end
