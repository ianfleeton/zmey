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
  if @product.purchase_nominal_code
    json.purchase_nominal_code do
      json.id   @product.purchase_nominal_code.id
      json.code @product.purchase_nominal_code.code
      json.href api_admin_nominal_code_url(@product.purchase_nominal_code)
    end
  end
  if @product.sales_nominal_code
    json.sales_nominal_code do
      json.id   @product.sales_nominal_code.id
      json.code @product.sales_nominal_code.code
      json.href api_admin_nominal_code_url(@product.sales_nominal_code)
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
