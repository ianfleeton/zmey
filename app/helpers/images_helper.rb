module ImagesHelper
  # Returns image options for a select field for the given +website+.
  def image_options(website)
    [['No image', nil]] +
      Image.where(website_id: website.id).order(:name).pluck(:name, :id)
  end

  # Returns a cache key for the collection of all images in +website+.
  def images_cache_key(website)
    [
      website.images.count,
      Image.where(website_id: website.id).order('updated_at DESC').first
    ]
  end
end
