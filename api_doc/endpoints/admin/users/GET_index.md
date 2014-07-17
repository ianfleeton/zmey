# GET api/admin/users

Returns a summary list of all users.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/users
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

```json
{
  "users": [
    {
      "id": 1,
      "name": "Joanne Shopper",
      "email": "shopper@example.com"
    },
    {
      "id": 2,
      "name": "Bill Buyer",
      "email": "buyer@example.org"
    }
  ]
}  
```
