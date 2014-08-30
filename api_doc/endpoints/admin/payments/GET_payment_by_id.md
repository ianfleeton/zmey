# GET api/admin/payments/:id

Returns detailed information for a payment.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/payments/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the payment is found, otherwise **404 Not Found** is
returned.

```json
{
  "payment": {
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
    "installation_id": "paypalaccount@example.com",
    "cart_id": "20140829-AX0W",
    "description": "Web Purchase",
    "test_mode": false,
    "name": "Natalya",
    "address": "123 Street",
    "postcode": "L0N D0N",
    "country": "GB",
    "telephone": "01234 567890",
    "fax": "",
    "email": "natalya@example.org",
    "transaction_id": "18P93015N5395810F",
    "transaction_status": "1",
    "transaction_time": "09:25:27 Aug 29, 2014 PDT",
    "raw_auth_message": "SUCCESS...",
    "created_at": "2014-08-29T17:25:28.000+01:00",
    "updated_at": "2014-08-29T17:25:28.000+01:00"
  }
}
```
