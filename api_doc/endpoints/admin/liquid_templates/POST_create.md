# POST api/admin/liquid_templates

Create a new Liquid template.

## Attributes

### Required attributes

* **markup** — Content of the template which may contain Liquid markup.
* **name** — Unique name of the template.

### Additional attributes

* **title** — Title for the template.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/liquid_templates \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "liquid_template[markup]=Some markup" \
  -d "liquid_template[name]=home.footer.social" \
  -d "liquid_template[title]=Follow Us"
```

### Response

A status of 422 Unprocessable Entity will be returned if the Liquid template cannot be
created.

```json
{
  "liquid_template": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/liquid_templates/1"
  }
}
```
