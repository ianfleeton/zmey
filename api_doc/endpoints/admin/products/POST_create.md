# POST api/admin/products

Create a new product.

## Attributes

### Required attributes

* **name** — Name of the product
* **sku** — SKU

### Additional attributes

* **brand** — Brand / manufacturer of the product. Used in Google Shopping feed.
* **description** — A description of the product.
* **image_id** — ID of the main product image.
* **meta_description** — A description meta tag for the product's main page. Maximum length is 255 characters.
* **page_title** — Title of the HTML document for the product's main page.
* **price** — Price of the product with decimal to separate pounds and pence,
for example, 10.99.
* **tax_type** — Tax type of the product (see table below).
* **weight** — Weight of the product (decimal).

#### Tax types

|tax_type|Description|
|--------|-----------|
|1       |This product is not taxable|
|2       |Taxable — price given includes VAT|
|3       |Taxable — price given excludes VAT|

## Example

### Request

```
curl https://zmey.co.uk/api/admin/products \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d product[sku]=CB01 \
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
