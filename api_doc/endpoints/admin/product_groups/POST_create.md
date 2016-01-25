# POST api/admin/product_groups

Create a new product group.

## Attributes

### Required attributes

* **name** — Unique name of the product group.

### Additional attributes

* **location** — Where the stock of products in this group are located, such as
a particular warehouse.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/product_groups \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "product_group[name]=Bulky items" \
  -d "product_group[location]=South warehouse"
```

### Response

A status of 422 Unprocessable Entity will be returned if the product group
cannot be created.

```json
{
  "product_group": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/product_groups/1"
  }
}
```
