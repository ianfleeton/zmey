# POST api/admin/product_placements

Places a product within a page.

## Attributes

### Required attributes

* **page_id** — ID of the page
* **product_id** — ID of the product

## Example

### Request

```
curl https://zmey.co.uk/api/admin/product_placements \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d product_placement[page_id]=2 \
  -d product_placement[product_id]=3
```

### Response

A status of 422 Unprocessable Entity will be returned if the product placement
cannot be created.

```json
{
  "product_placement": {
    "id": 1
  }
}
```
