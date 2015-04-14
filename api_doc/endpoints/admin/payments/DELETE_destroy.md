# DELETE api/admin/payments/:id

Deletes a payment.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/payments/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -X DELETE
```

### Response

A status of 404 will be returned if the payment does not exist or has been
previously deleted. 204 is returned upon successful deletion.
