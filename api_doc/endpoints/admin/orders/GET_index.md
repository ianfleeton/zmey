# GET api/admin/orders

Returns a summary list of all orders.

## Parameters

* **page** — Page number of results. Numbering starts from 1. Default is 1.
* **page_size** — Number of results per page. Default is 50.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/orders \
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
      "user": {
        "id": 1,
        "href": "https://zmey.co.uk/api/admin/users/1"
      },
      "email_address": "shopper@example.org",
      "total": "350.0",
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
      "created_at": "2014-04-12T10:00:00.000+01:00",
      "updated_at": "2014-04-12T10:00:00.000+01:00"
    }
  ],
  "count": 2
}
```
