# POST api/admin/products

Create a new product.

## Attributes

### Required attributes

* **name** — Name of the product
* **sku** — SKU

### Additional attributes

* **price** — Price of the product with decimal to separate pounds and pence,
for example, 10.99.
* **description** — A description of the product.
* **meta_description** — A description meta tag for the product's main page.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/products
  -u 22cbbfeaef6085872dbe6c0e978fa098:
  -d product[sku]=CB01
  -d "product[name]=Cool Beans"
```

### Response

A status of 422 Unprocessable Entity will be returned if the product cannot be
created.

```json
{
  "product": {
    "id": 1
  }
}
```