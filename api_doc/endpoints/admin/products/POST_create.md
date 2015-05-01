# POST api/admin/products

Create a new product.

## Attributes

### Required attributes

* **name** — Name of the product
* **sku** — SKU

### Additional attributes

* **allow_fractional_quantity** — Whether a fractional amount of this product can be added to the basket. Useful for products sold by weight, volume, length or area. Default is false.
* **brand** — Brand / manufacturer of the product. Used in Google Shopping feed.
* **description** — A description of the product.
* **extra** — Additional custom JSON data.
* **google_description** — An alternative description to use in Google feeds to meet editorial guidelines.
* **image_id** — ID of the main product image.
* **meta_description** — A description meta tag for the product's main page. Maximum length is 255 characters.
* **purchase_nominal_code** and **sales_nominal_code** — A nominal (account) code for use in external accounts software packages. The code must match an existing nominal code in the system.
* **page_title** — Title of the HTML document for the product's main page.
* **price** — Price of the product with decimal to separate pounds and pence,
for example, 10.99.
* **rrp** — Recommended retail price.
* **submit_to_google** — Whether or not the product should be submitted to Google in the product feed.
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
