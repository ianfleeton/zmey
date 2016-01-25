# DELETE api/admin/product_groups

Deletes all product groups from the website. All relationships with this group
are removed as appropriate.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/product_groups \
  -X DELETE \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**204 No Content** is returned if the action was carried out successfully.
