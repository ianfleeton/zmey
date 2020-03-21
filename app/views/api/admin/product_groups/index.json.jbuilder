json.product_groups(@product_groups) do |group|
  json.id group.id
  json.href api_admin_product_group_url(group)
  json.name group.name
end
