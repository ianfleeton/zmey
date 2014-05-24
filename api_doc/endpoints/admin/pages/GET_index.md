# GET api/admin/pages

Returns a list of all pages.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/pages
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

```json
{
  "pages": [
    {
      "id": 1,
      "parent_id": null,
      "slug": "tools",
      "title": "Tools"
    },
    {
      "id": 2,
      "parent_id": 1,
      "slug": "hammers",
      "title": "Hammers"
    },
    {
      "id": 3,
      "parent_id": 1,
      "slug": "saws",
      "title": "Saws"
    }
  ]
}  
```
