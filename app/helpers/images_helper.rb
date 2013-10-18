module ImagesHelper
  def image_options
    [['No image', nil]] +
      Image.where(website_id: @w.id).order(:name).pluck(:name, :id)
  end
end
