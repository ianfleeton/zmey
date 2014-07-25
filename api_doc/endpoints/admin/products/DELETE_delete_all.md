# DELETE api/admin/products

Deletes all products from the website. All product relationships are removed as
appropriate.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/products \
  -X DELETE \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**204 No Content** is returned if the action was carried out successfully.
