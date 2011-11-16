Given /^there is one product in the shop$/ do
  Product.create!(:website_id => 1, :sku => 'EPI-SG', :name => 'Epiphone SG', :price => '269.99')
end
