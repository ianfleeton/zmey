class Api::Admin::ImagesController < Api::Admin::AdminController
  def index
    @images = website.images
  end

  def show
    @image = Image.find_by(id: params[:id], website_id: website.id)
    render nothing: true, status: 404 unless @image
  end

  def create
    @image = Image.new(image_params)
    io = StringIO.new(Base64.decode64(params[:image][:data]))
    @image.image = io
    @image.website = website
    if @image.save
      Webhook.trigger('image_created', @image)
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    begin
      website.images.destroy_all
      render nothing: :true, status: 204
    rescue ActiveRecord::DeleteRestrictionError => e
      render json: {'error' => e.to_s}, status: 400
    end
  end

  private

    def image_params
      params.require(:image).permit(:name)
    end
end
