class Api::Admin::CarouselSlidesController < Api::Admin::AdminController
  def delete_all
    website.carousel_slides.destroy_all
    render nothing: :true, status: 204
  end
end
