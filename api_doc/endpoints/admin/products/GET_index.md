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

```json
{
  "products": [
    {
      "id": 1,
      "sku": "HMR14",
      "name": "Hammer"
    },
    {
      "id": 2,
      "sku": "NLS28",
      "name": "Nails"
    }
  ]
}  
```
