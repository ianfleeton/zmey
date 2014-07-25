# DELETE api/admin/pages

Deletes all pages from the website. All page relationships are removed as
appropriate.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/pages \
  -X DELETE \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**204 No Content** is returned if the action was carried out successfully.
