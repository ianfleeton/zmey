json.payment do
  json.id @payment.id
  json.href api_admin_payment_url(@payment)
  json.amount @payment.amount
  json.currency @payment.currency
  json.accepted @payment.accepted
  json.service_provider @payment.service_provider
  json.installation_id @payment.installation_id
  json.cart_id @payment.cart_id
  json.description @payment.description
  json.test_mode @payment.test_mode
  json.name @payment.name
  json.address @payment.address
  json.postcode @payment.postcode
  json.country @payment.country
  json.telephone @payment.telephone
  json.fax @payment.fax
  json.email @payment.email
  json.transaction_id @payment.transaction_id
  json.transaction_status @payment.transaction_status
  json.transaction_time @payment.transaction_time
  json.raw_auth_message @payment.raw_auth_message
  json.created_at @payment.created_at
  json.updated_at @payment.updated_at
  if @payment.order
    json.order do
      json.id @payment.order.id
      json.href api_admin_order_url(@payment.order)
    end
  end
end
