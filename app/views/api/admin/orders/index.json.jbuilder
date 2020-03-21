json.orders(@orders) do |order|
  json.id order.id
  json.href api_admin_order_url(order)
  json.order_number order.order_number
  if order.user
    json.user do
      json.id order.user.id
      json.href api_admin_user_url(order.user)
    end
  end
  json.email_address order.email_address
  json.total order.total
  json.status Enums::PaymentStatus.new(order.status).to_api
  json.processed_at order.processed_at
  json.created_at order.created_at
  json.updated_at order.updated_at
end

json.count @orders.total_entries
