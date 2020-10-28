# POST api/admin/shipments

Create a new shipment.

## Attributes

### Required attributes

* **courier_id** — ID of the courier to which the shipment belongs.
* **order_id** — ID of the order to which the shipment belongs.

### Additional attributes

* **consignment_number** — Tracking number or ID for tracking the delivery
* **number_of_parcels**
* **partial** — Is this a partial order? Set to true when there will be further
  shipments required to complete the order. If this is the last shipment for the
  order then set to false.
* **picked_by** — Name of the person who picked the items in this shipment.
* **total_weight** — Decimal. Weight of the shipment in kilograms.
  with the shipping company. Can contain alphanumeric characters.
* **tracking_url** — URL that the customer can visit to track their delivery.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/shipments \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "shipment[consignment_number]=C123" \
  -d "shipment[courier_id]=9" \
  -d "shipment[number_of_parcels]=3" \
  -d "shipment[order_id]=123" \
  -d "shipment[partial]=true" \
  -d "shipment[picked_by]=Jo Picker" \
  -d "shipment[total_weight]=1.234" \
  -d "shipment[tracking_url]=http://trackyourorder.url/123"
```

### Response

A status of 422 Unprocessable Entity will be returned if the shipment cannot be
created.

```json
{
  "shipment": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/shipment/1"
  }
}
```
