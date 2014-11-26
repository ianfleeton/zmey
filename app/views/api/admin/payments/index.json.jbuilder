json.payments(@payments) do |payment|
  json.id               payment.id
  json.href             api_admin_payment_url(payment)
  json.amount           payment.amount
  json.currency         payment.currency
  json.accepted         payment.accepted
  json.service_provider payment.service_provider
  json.test_mode        payment.test_mode
  json.created_at       payment.created_at
  json.updated_at       payment.updated_at
  if payment.order
    json.order do
      json.id   payment.order.id
      json.href api_admin_order_url(payment.order)
    end
  end
end
