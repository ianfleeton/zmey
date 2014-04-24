class Api::Admin::ImagesController < Api::Admin::AdminController
  def index
    @images = website.images
    render nothing: true, status: 404 if @images.empty?
  end
end
