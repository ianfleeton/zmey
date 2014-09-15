# GET api/admin/images

Returns a list of all images.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/images \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

```json
{
  "images": [
    {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/images/1",
      "filename": "image.jpg",
      "name": "Hammer"
    },
    {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/images/2",
      "filename": "image.png",
      "name": "Nails"
    }
  ]
}  
```
