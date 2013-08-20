class ImagesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required

  def index
    @images = @w.images
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)

    @image.website_id = @w.id
    
    if @image.save
      flash[:notice] = 'Image uploaded.'
      redirect_to action: 'index'
    else
      render action: 'new'
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
      render action: 'edit'
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