json.images(@images) do |image|
  json.id image.id
  json.filename image.filename
  json.name image.name
end
