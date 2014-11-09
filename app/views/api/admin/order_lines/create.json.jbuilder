json.order_line do
  json.id   @order_line.id
  json.href api_admin_order_line_url(@order_line)
end
