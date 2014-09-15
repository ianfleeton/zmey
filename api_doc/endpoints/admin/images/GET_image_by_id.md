# GET api/admin/images/:id

Returns detailed information for an image, including its raw image data.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/image/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the image is found, otherwise **404 Not Found** is
returned.

```json
{
  "image": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/images/1",
    "filename": "image.jpg",
    "name": "Product Front",
    "data": "(Base64 encoded data)",
    "created_at": "2014-08-29T17:25:28.000+01:00",
    "updated_at": "2014-08-29T17:25:28.000+01:00"
  }
}
```
