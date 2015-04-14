# POST api/admin/payments

Create a new payment.

## Attributes

### Required attributes

* **accepted** — Whether or not the payment was accepted.
* **amount** — Payment amount with decimal to separate pounds from pence.
* **order_id** — ID of the order to which the payment belongs.
* **service_provider** — Either the name of the payment service provider or of
  the payment method, for example "PayPal" or "BACS".

### Additional attributes

* **raw_auth_message** — Message provided by the service provider or any other
  message to describe the payment transaction.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/payments \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "payment[order_id]=123" \
  -d "payment[accepted]=true" \
  -d "payment[amount]=9.99" \
  -d "payment[service_provider]=MOTO" \
  -d "payment[raw_auth_message]=Credit card payment by phone"
```

### Response

A status of 422 Unprocessable Entity will be returned if the payment cannot be
created.

```json
{
  "payment": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/payments/1"
  }
}
```
