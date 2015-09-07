# GET api/admin/product_groups/:id

Returns detailed information for a product group.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/product_groups/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the product group is found, otherwise **404 Not
Found** is returned.

```json
{
  "product_group": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/product_groups/1",
    "name": "Bulky items",
    "location": "South warehouse"
  }
}
```
