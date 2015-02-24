# GET api/admin/products

Returns a summary list of all products.

## Parameters

* **updated_since** — A time in ISO 8601 format. Returns only products that
  have been updated since (on or after) this time.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/products \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

The `now` key gives the time at which the products were fetched. This time
can be used in a subsequent call using `updated_since` which guarantees that
any products added or updated updated since this request will be included.

```json
{
  "now": "2015-02-24T15:49:10.000+00:00",
  "products": [
    {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/products/1",
      "sku": "HMR14",
      "name": "Hammer"
    },
    {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/products/2",
      "sku": "NLS28",
      "name": "Nails"
    }
  ]
}
```
