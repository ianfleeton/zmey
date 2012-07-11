Given /^there is one product in the shop$/ do
  p = Product.new(sku: 'EPI-SG', name: 'Epiphone SG', price: '269.99')
  p.website_id = 1
  p.save!
end
