# PATCH api/admin/orders/:id

Update an existing order.

## Attributes

* **processed_at** — When the order was externally processed.

## Example

### Request

```
curl -X PATCH https://zmey.co.uk/api/admin/orders/1 \
     -u 22cbbfeaef6085872dbe6c0e978fa098: \
     -d "order[processed_at]=2014-05-14T14:03:56.000+01:00"
```

### Response

**204 No Content** is returned when the order is updated, otherwise **404 Not Found** is
returned.
