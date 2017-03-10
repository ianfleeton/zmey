json.product do
  json.id     @product.id
  json.href   api_admin_product_url(@product)
  json.sku    @product.sku
  json.name   @product.name
  json.price  @product.price
  json.weight @product.weight
  if @product.image
    json.image do
      json.id   @product.image.id
      json.href api_admin_image_url(@product.image)
    end
  end
  json.product_groups(@product.product_groups) do |g|
    json.id g.id
    json.href api_admin_product_group_url(g)
  end
  json.description        @product.description
  json.in_stock           @product.in_stock
  json.google_description @product.google_description
  @product.extra_attributes.each do |name, value|
    json.set! name, value
  end
end
