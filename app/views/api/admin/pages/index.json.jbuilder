json.pages(@pages) do |page|
  json.id page.id
  json.parent_id page.parent_id
  json.slug page.slug
  json.title page.title
end
