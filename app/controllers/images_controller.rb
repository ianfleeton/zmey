class ImagesController < ApplicationController
  # Returns a dynamically sized image. This action is triggered when the sized
  # image does not yet exist.
  def sized_image
    path = Image.sized_path(params[:id], params[:filename])
    send_file(path, disposition: :inline)
  end
end
