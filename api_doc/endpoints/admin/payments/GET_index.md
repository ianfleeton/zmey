# GET api/admin/payments

Returns a summary list of all payments.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/payments \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

```json
{
  "payments": [
    {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/payments/1",
      "order": {
        "id": 1,
        "href": "https://zmey.co.uk/api/admin/orders/1"
      },
      "amount": "24.99",
      "currency": "GBP",
      "accepted": true,
      "service_provider": "PayPal",
      "test_mode": false,
      "created_at": "2014-08-29T17:25:28.000+01:00",
      "updated_at": "2014-08-29T17:25:28.000+01:00"
    },
    {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/payments/2",
      "order": {
        "id": 2,
        "href": "https://zmey.co.uk/api/admin/orders/2"
      },
      "amount": "49.50",
      "currency": "USD",
      "accepted": true,
      "service_provider": "WorldPay",
      "test_mode": false,
      "created_at": "2014-08-29T17:28:12.000+01:00",
      "updated_at": "2014-08-29T17:28:12.000+01:00"
    }
  ]
}
```
