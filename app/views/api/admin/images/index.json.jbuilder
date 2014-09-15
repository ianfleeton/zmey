json.images(@images) do |image|
  json.id       image.id
  json.href     api_admin_image_url(image)
  json.filename image.filename
  json.name     image.name
end
