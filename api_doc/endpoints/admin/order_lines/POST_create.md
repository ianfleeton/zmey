# POST api/admin/order_lines

Create a new order line.

## Attributes

### Required attributes

* **order_id** — ID of the order to which the order line belongs
* **quantity** — Product quantity

and either

* **product_id** — ID of the product

or

* **product_sku** — SKU
* **product_price** — Price excluding tax for a single product
* **tax_amount** — Total amount of tax for **quantity** products

## Example

### Request

```
curl https://zmey.co.uk/api/admin/order_lines \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "order_line[order_id]=12" \
  -d "order_line[product_id]=34" \
  -d "order_line[quantity]=2"
```

### Response

A status of 422 Unprocessable Entity will be returned if the order line cannot be
created.

```json
{
  "order_line": {
    "id": 101,
    "href": "https://zmey.co.uk/api/admin/order_lines/1"
  }
}
```
