json.page do
  json.id @page.id
  json.href api_admin_page_url(@page)
  if @page.parent
    json.parent do
      json.id @page.parent.id
      json.href api_admin_page_url(@page.parent)
    end
  end
  json.slug @page.slug
  json.title @page.title
  json.name @page.name
  json.description @page.description
  json.content @page.content
  json.position @page.position
  if @page.image
    json.image do
      json.id @page.image.id
      json.href api_admin_image_url(@page.image)
    end
  end
  if @page.thumbnail_image
    json.thumbnail_image do
      json.id @page.thumbnail_image.id
      json.href api_admin_image_url(@page.thumbnail_image)
    end
  end
  json.no_follow @page.no_follow
  json.no_index @page.no_index
  json.extra @page.extra
end
