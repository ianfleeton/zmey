class Api::Admin::ImagesController < Api::Admin::AdminController
  def index
    @images = website.images
    render nothing: true, status: 404 if @images.empty?
  end

  def delete_all
    website.images.destroy_all
    render nothing: :true, status: 204
  end
end
