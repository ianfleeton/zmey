# POST api/admin/orders

Create a new order.

## Attributes

### Required attributes

* **billing_address_line_1**
* **billing_country_id**
* **billing_postcode**
* **billing_town_city**
* **delivery_address_line_1**
* **delivery_country_id**
* **delivery_postcode**
* **delivery_town_city**
* **email_address** — Customer's email address.
* **status** — Payment status (see table below).

#### Status values

**status** can be one of:

* payment_on_account
* payment_received
* waiting_for_payment

### Additional attributes

* **billing_address_line_2**
* **customer_note** — A note left by the customer such as delivery instructions.
* **delivery_address_line_2**
* **delivery_full_name** — Full name of the customer.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/orders \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "order[billing_address_line_1]=123 Street" \
  -d "order[billing_country_id]=1" \
  -d "order[billing_postcode]=HG1 9ZZ" \
  -d "order[billing_town_city]=Harrogate" \
  -d "order[delivery_address_line_1]=123 Street" \
  -d "order[delivery_country_id]=1" \
  -d "order[delivery_postcode]=HG1 9ZZ" \
  -d "order[delivery_town_city]=Harrogate" \
  -d "order[email_address]=shopper@example.org",
  -d "order[status]=payment_received"
```

### Response

A status of 422 Unprocessable Entity will be returned if the order cannot be
created.

```json
{
  "order": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/orders/1"
  }
}
```
