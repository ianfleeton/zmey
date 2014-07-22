# DELETE api/admin/images

Deletes all images from the website. All image relationships are removed as
appropriate and where possible.

If any image belongs to an object that requires an image, such as a carousel
slide, then the owning object should be deleted first.

## Example

### Request

`DELETE api/admin/images`

### Response

**204 No Content** is returned if the action was carried out successfully.
**400 Bad Request** is returned if an image cannot be deleted because it
is required by another object.
