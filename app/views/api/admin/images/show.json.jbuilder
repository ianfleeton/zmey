json.image do
  json.id         @image.id
  json.href       api_admin_image_url(@image)
  json.name       @image.name
  json.filename   @image.filename
  json.data       @image.data_base64
  json.created_at @image.created_at
  json.updated_at @image.updated_at
end
