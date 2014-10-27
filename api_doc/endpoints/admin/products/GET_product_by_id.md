# GET api/admin/products/:id

Returns detailed information for a product.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/products/1 \
  -u 22cbbfeaef6085872dbe6c0e978fa098:
```

### Response

**200 OK** is returned when the product is found, otherwise **404 Not Found** is
returned.

```json
{
  "product": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/products/1",
    "sku": "SKU-1",
    "name": "iDevice",
    "price": "299.0",
    "image": {
      "id": 1,
      "href": "https://zmey.co.uk/api/admin/images/1"
    },
    "nominal_code": {
      "id": 1,
      "code": "4000",
      "href": "https://zmey.co.uk/api/admin/nominal_codes/1"
    },
    "description": "Shiny shiny designed in California",
    "in_stock": true,
    "google_description": ""
  }
}
```
