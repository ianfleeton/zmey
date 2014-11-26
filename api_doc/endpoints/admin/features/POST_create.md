# POST api/admin/features

Create a new product feature.

## Attributes

### Required attributes

* **name** — Name of the feature, for example 'Size' or 'Colour'.
* **product_id** — The product this feature belongs to.

### Additional attributes

None yet.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/features \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "feature[name]=Size" \
  -d "feature[product_id]=1"
```

### Response

A status of 422 Unprocessable Entity will be returned if the feature cannot be
created.

```json
{
  "feature": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/features/1"
  }
}
```
