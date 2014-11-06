# GET api/admin/countries

Returns a summary list of all countries.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/countries \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

```json
{
  "countries": [
    {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/countries/1",
      "name": "United Kingdom"
    },
    {
      "id": 2,
      "href": "https://zmey.co.uk/api/admin/countries/2",
      "name": "France"
    }
  ]
}  
```
