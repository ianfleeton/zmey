# GET api/admin/orders/:id

Returns detailed information for an order.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/orders/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the order is found, otherwise **404 Not Found** is
returned.

```json
{
  "order": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/orders/1",
    "order_number": "20140411-AX0W",
    "user": {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/users/1"
    },
    "email_address": "shopper@example.org",
    "delivery_full_name": "A. Shopper",
    "delivery_address_line_1": "123 Street",
    "delivery_address_line_2": "",
    "delivery_town_city": "Doncaster",
    "delivery_county": "South Yorkshire",
    "delivery_postcode": "DN99 9ZZ",
    "delivery_phone_number": "01234 567890",
    "shipping_amount": "0.0",
    "shipping_tax_amount": "0.0",
    "shipping_method": "Free Shipping",
    "status": "payment_received",
    "total": "17.5",
    "ip_address": "127.0.0.1",
    "created_at": "2014-04-11T10:00:00.000+01:00",
    "updated_at": "2014-04-11T10:00:00.000+01:00",
    "order_lines": [
      {
        "id": 1,
        "href": "https://zmey.co.uk/api/admin/order_lines/1",
        "product": {
          "id": 1,
          "href": "https://zmey.co.uk/api/admin/products/1"
        },
        "product_name": "Hammer",
        "product_sku": "HMR01",
        "product_price": "17.5",
        "product_weight": "1.2",
        "tax_amount": "0.0",
        "feature_descriptions": "",
        "shipped": false,
        "created_at": "2014-04-11T10:00:00.000+01:00",
        "updated_at": "2014-04-11T10:00:00.000+01:00"
      }
    ],
    "payments": [
      {
        "id": 1,
        "href": "https://zmey.co.uk/api/admin/payments/1",
        "amount": "17.5",
        "accepted": true,
        "service_provider": "WorldPay"
      }
    ]
  }
}
```
