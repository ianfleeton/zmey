json.product_group do
  json.id       @product_group.id
  json.href     api_admin_product_group_url(@product_group)
  json.name     @product_group.name
  json.location @product_group.location
  json.products(@product_group.products) do |p|
    json.id p.id
    json.href api_admin_product_url(p)
  end
end
