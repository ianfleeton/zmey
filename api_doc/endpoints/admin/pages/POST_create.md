# POST api/admin/pages

Create a new page.

## Attributes

### Required attributes

* **description** — A description meta tag. Maximum length is 200 characters.
* **name** — Name of the page.
* **slug** — Used to form the page's URL. Can contain numbers, lowercase
letters, hyphens and forward slashes.
* **title** — Title of the page, used for the HTML document title.

### Additional attributes

* **parent_id** — ID of the parent page. If not provided, null is assumed.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/pages
  -u 22cbbfeaef6085872dbe6c0e978fa098:
  -d "page[description]=All kinds of hammers for DIY and professional use"
  -d "page[name]=Hammers"
  -d "page[slug]=tools/hammers"
  -d "page[title]=Hammers | Tools"
```

### Response

A status of 422 Unprocessable Entity will be returned if the product cannot be
created.

```json
{
  "page": {
    "id": 1
  }
}
```
