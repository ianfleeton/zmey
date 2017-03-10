class Api::Admin::ImagesController < Api::Admin::AdminController
  def index
    @images = Image.all
  end

  def show
    @image = Image.find_by(id: params[:id])
    head 404 unless @image
  end

  def create
    @image = Image.new(image_params)
    io = StringIO.new(Base64.decode64(params[:image][:data]))
    @image.image = io
    if @image.save
      Webhook.trigger('image_created', @image)
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    begin
      Image.fast_delete_all
      head 204
    rescue ActiveRecord::DeleteRestrictionError => e
      render json: {'error' => e.to_s}, status: 400
    end
  end

  private

    def image_params
      params.require(:image).permit(:name)
    end
end
