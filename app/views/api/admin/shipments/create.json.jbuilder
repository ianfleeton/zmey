json.shipment do
  json.id @shipment.id
  json.href api_admin_shipment_url(@shipment)
end
