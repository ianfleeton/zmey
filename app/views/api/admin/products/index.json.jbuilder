json.products(@products) do |product|
  json.id   product.id
  json.href api_admin_product_url(product)
  json.sku  product.sku
  json.name product.name
end
