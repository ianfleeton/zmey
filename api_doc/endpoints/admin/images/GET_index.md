# GET api/admin/images

Returns a list of all images.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/images
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

A status of 404 will be returned if there are no images.

```json
{
  "images": [
    {
      "id": 1,
      "filename": "image.jpg",
      "name": "Hammer"
    },
    {
      "id": 2,
      "filename": "image.png",
      "name": "Nails"
    }
  ]
}  
```