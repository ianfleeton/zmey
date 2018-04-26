# DELETE api/admin/images

Deletes all images from the website. All image relationships are removed as
appropriate and where possible.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/images \
  -X DELETE \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**204 No Content** is returned if the action was carried out successfully.
**400 Bad Request** is returned if an image cannot be deleted because it
is required by another object.
