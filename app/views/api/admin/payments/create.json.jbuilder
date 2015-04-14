json.payment do
  json.id @payment.id
  json.href api_admin_payment_url(@payment)
end
