# POST api/admin/orders

Create a new order.

## Attributes

### Required attributes

* **billing_address_line_1**
* **billing_country_id** or **billing_country_name**
* **billing_postcode**
* **billing_town_city**
* **delivery_address_line_1**
* **delivery_country_id** or **delivery_country_name**
* **delivery_postcode**
* **delivery_town_city**
* **email_address** — Customer's email address.
* **status** — Payment status (see table below).

#### Status values

**status** can be one of:

* payment_on_account
* payment_received
* quote
* waiting_for_payment

### Additional attributes

* **billing_address_line_2**
* **billing_address_line_3**
* **billing_county**
* **billing_full_name** — Full name of the customer.
* **customer_note** — A note left by the customer.
* **delivery_address_line_2**
* **delivery_address_line_3**
* **delivery_county**
* **delivery_full_name** — Full name of the customer.
* **delivery_instructions** — Delivery instructions left by the customer.
* **order_number** — Order number, which is represented as a string so it can
  contain letters as well as numbers.
* **po_number** — Customer's purchase order (PO) number.
* **processed_at** — Time when the order was processed or exported to an
  external system.

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
  -d "order[email_address]=shopper@example.org" \
  -d "order[processed_at]=2015-03-05T10:00:00.000+00:00" \
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
