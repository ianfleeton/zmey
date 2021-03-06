# GET api/admin/orders

Returns a summary list of all orders.

## Parameters

* **order_number** — Filters by order number. Returns a maximum of 1 result.
* **page** — Page number of results. Numbering starts from 1. Default is 1.
* **page_size** — Number of results per page. Default is 50.
* **processed** — Boolean filter to only include processed (when true) or
  unprocessed (when false) orders.
* **status** — Filters the orders by payment status. Can be one or more of:
  waiting_for_payment, payment_received, payment_on_account or quote. Separate
  multiple statuses with a pipe character (|).

## Example

### Request

Retrieve up to 50 most recent orders:

```
curl https://zmey.co.uk/api/admin/orders \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

Retrieve unprocessed orders where payment has been received:

```
curl 'https://zmey.co.uk/api/admin/orders?status=payment_received&processed=false' \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

The response contains a total count of all matching orders in the **count**
attribute.

```json
{
  "orders": [
    {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/orders/1",
      "order_number": "20140411-AX0W",
      "po_number": "PO1234",
      "user": {
        "id": 1,
        "href": "https://zmey.co.uk/api/admin/users/1"
      },
      "email_address": "shopper@example.org",
      "total": "350.0",
      "status": "waiting_for_payment",
      "processed_at": null,
      "created_at": "2014-04-11T10:00:00.000+01:00",
      "updated_at": "2014-04-11T10:00:00.000+01:00"
    },
    {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/orders/2",
      "order_number": "20140412-B9Z1",
      "user": {
        "id": 2,
        "href": "https://zmey.co.uk/api/admin/users/2"
      },
      "email_address": "buyer@example.com",
      "total": "129.99",
      "status": "payment_received",
      "processed_at": null,
      "created_at": "2014-04-12T10:00:00.000+01:00",
      "updated_at": "2014-04-12T10:00:00.000+01:00"
    }
  ],
  "count": 2
}
```
