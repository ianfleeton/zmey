json.images(@images) do |image|
  json.id   image.id
  json.name image.name
  json.url  image.url
end
json.total_pages @images.total_pages
json.current_page @images.current_page
