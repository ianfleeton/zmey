json.basket do
  json.total_quantity @basket.total_quantity
  json.total_ex_vat @basket.total(false)
  json.total_inc_vat @basket.total(true)
  json.shipping_amount @shipping_amount
  json.shipping_vat_amount @shipping_vat_amount
  json.basket_items @basket.basket_items do |item|
    json.product_name item.product.name
    json.quantity item.quantity
  end
end
