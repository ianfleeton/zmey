class Api::Admin::CarouselSlidesController < Api::Admin::AdminController
  def create
    @carousel_slide = CarouselSlide.new(carousel_slide_params)

    if params[:image_id].present? && !Image.exists?(id: params[:image_id])
      @carousel_slide.errors.add(:base, 'Image does not exist.')
    end

    if @carousel_slide.errors.any? || !@carousel_slide.save
      render json: @carousel_slide.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    CarouselSlide.destroy_all
    render nothing: :true, status: 204
  end

  private

    def carousel_slide_params
      params.require(:carousel_slide).permit(
      :active_from,
      :active_until,
      :caption,
      :image_id,
      :link
      )
    end
end
