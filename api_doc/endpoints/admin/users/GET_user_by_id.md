# GET api/admin/users/:id

Returns detailed information for a user.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/users/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the user is found, otherwise **404 Not Found** is
returned.

```json
{
  "user": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/users/1",
    "name": "Joanne Shopper",
    "email": "shopper@example.com",
    "encrypted_password": "2f8f79e1a191924035ae8fc8af6937279311b704",
    "salt": "d49b4ad9cb8b9c7044710a1d57550909434e1d85",
    "forgot_password_token": "A59CZQAM",
    "customer_reference": "JS1410",
    "created_at": "2014-08-29T17:25:28.000+01:00",
    "updated_at": "2014-08-29T17:25:28.000+01:00"
  }
}
```
