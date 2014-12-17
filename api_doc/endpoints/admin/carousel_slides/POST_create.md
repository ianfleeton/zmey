# POST api/admin/carousel_slide

Create a new carousel slide.

## Attributes

### Required attributes

* **caption** — Slide's caption. Maximum length 255 characters.
* **image_id** — ID of the slide's image.
* **link** — URL that the slide should link to.

## Example

### Request

```
curl https://zmey.co.uk/api/admin/carousel_slides \
  -u 22cbbfeaef6085872dbe6c0e978fa098: \
  -d "carousel_slide[caption]=Black Friday Deals" \
  -d "carousel_slide[image_id]=123" \
  -d "carousel_slide[link]=/black-friday-deals"
```

### Response

A status of 422 Unprocessable Entity will be returned if the slide cannot be
created.

```json
{
  "carousel_slide": {
    "id": 1,
    "href": "https://zmey.co.uk/api/admin/carousel_slides/1"
  }
}
```
