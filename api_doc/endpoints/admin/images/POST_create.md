# POST api/admin/images

Create a new image and trigger the `image_created` webhook.

## Attributes

### Required attributes

* **name** — Name of the image. Must be unique.
* **data** — Base64 encoded image data.

### Additional attributes

None yet.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/images \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "image[name]=A box" \
  -d "image[data]=/9j/4A...AD//Z"
```

### Response

A status of 422 Unprocessable Entity will be returned if the image cannot be
created.

```json
{
  "image": {
    "id": 1
  }
}
```
