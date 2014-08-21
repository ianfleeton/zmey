json.product do
  json.id     @product.id
  json.href   api_admin_product_url(@product)
  json.sku    @product.sku
  json.name   @product.name
  json.price  @product.price
  if @product.image
    json.image do
      json.id   @product.image.id
      json.href api_admin_image_url(@product.image)
    end
  end
  json.description  @product.description
  json.in_stock     @product.in_stock
end
