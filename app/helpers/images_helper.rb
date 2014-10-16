module ImagesHelper
  def image_options
    [['No image', nil]] +
      Image.where(website_id: @w.id).order(:name).pluck(:name, :id)
  end

  # Returns a cache key for the collection of all images in +website+.
  def images_cache_key(website)
    [
      website.images.count,
      Image.where(website_id: website.id).order('updated_at DESC').first
    ]
  end
end
