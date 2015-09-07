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

The response contains various product attributes. It is also populated with any
defined extra attributes for products, such as `length` in the example below.

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
    "purchase_nominal_code": {
      "id": 1,
      "code": "4000",
      "href": "https://zmey.co.uk/api/admin/nominal_codes/1"
    },
    "product_groups": [
      {
        "id": 2,
        "href": "https://zmey.co.uk/api/admin/product_groups/2"
      }
    ],
    "description": "Shiny shiny designed in California",
    "in_stock": true,
    "google_description": "",
    "length": "138"
  }
}
```
