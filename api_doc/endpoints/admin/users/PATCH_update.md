# PATCH api/admin/users/:id

Update an existing user.

## Attributes

* **customer_reference** — The customer account reference for use with
  external systems.

## Example

### Request

```
curl -X PATCH https://zmey.co.uk/api/admin/users/1 \
     -u 22cbbfeaef6085872dbe6c0e978fa098: \
     -d "user[customer_reference]=ABUY1234"
```

### Response

**204 No Content** is returned when the user is updated, otherwise **404 Not Found** is
returned.
