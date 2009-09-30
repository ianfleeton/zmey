Given /^a product with features$/ do
  product = products(:amplifier)
  pp = ProductPlacement.new
  pp.product_id = product.id
  pp.page_id = pages(:guitar_gear_home).id
  pp.save!
end
