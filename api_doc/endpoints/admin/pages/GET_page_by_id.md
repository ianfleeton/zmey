# GET api/admin/pages/:id

Returns detailed information for a page.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/pages/3 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the page is found, otherwise **404 Not Found** is
returned.

```json
{
  "page": {
    "id": 3,
    "href": "https://zmey.co.uk/api/admin/pages/3",
    "parent": {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/pages/1"
    },
    "slug": "about",
    "title": "About Your e Solutions Ltd",
    "name": "About",
    "description": "Meta description...",
    "content": "<p>About our company...</p>",
    "position": 1,
    "image": {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/images/1"
    },
    "thumbnail_image": {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/images/2"
    },
    "no_follow": false,
    "no_index": false,
    "extra": "",
    "created_at": "2014-08-29T17:25:28.000+01:00",
    "updated_at": "2014-08-29T17:25:28.000+01:00"
  }
}
```
