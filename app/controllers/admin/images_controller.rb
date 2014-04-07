include ActionView::Helpers::TextHelper

class Admin::ImagesController < Admin::AdminController
  def index
    @images = website.images
  end

  def new
    @image = Image.new
  end

  def create
    uploader = website.image_uploader(image_params)

    flash[:notice] = "#{pluralize(uploader.images.length, 'image')} uploaded."

    if uploader.images.length > 0
      redirect_to admin_images_path
    else
      @image = uploader.failed.first || Image.new
      render :new
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(image_params)
      flash[:notice] = 'Image saved.'
      redirect_to action: 'index'
    else
      render :edit
    end
  end

  def destroy
    @image = Image.find(params[:id])
    begin
      @image.destroy
      flash[:notice] = 'Image deleted.'
    rescue ActiveRecord::DeleteRestrictionError => e
      @image.errors.add(:base, e)
      redirect_to(edit_image_path(@image), alert: "#{e}") and return
    end
    redirect_to images_path
  end

  private

    def image_params
      params.require(:image).permit(:image, :name)
    end
end
