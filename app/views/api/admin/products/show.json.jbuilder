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
  if @product.nominal_code
    json.nominal_code do
      json.id   @product.nominal_code.id
      json.code @product.nominal_code.code
      json.href api_admin_nominal_code_url(@product.nominal_code)
    end
  end
  json.description        @product.description
  json.in_stock           @product.in_stock
  json.google_description @product.google_description
end
