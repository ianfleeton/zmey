json.products(@products) do |product|
  json.id product.id
  json.sku product.sku
  json.name product.name
end
