module Admin
  class ImagesController < Admin::AdminController
    include ActionView::Helpers::TextHelper

    def index
      @images = Image.paginate(page: params[:page], per_page: params[:per_page] || 100)
      respond_to do |format|
        format.html
        format.json
      end
    end

    def new
      @image = Image.new
    end

    def create
      uploader = website.image_uploader(image_params)

      flash[:notice] = "#{pluralize(uploader.images.length, "image")} uploaded."

      if uploader.images.length > 0
        uploader.images.each { |i| Webhook.trigger("image_created", i) }
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
        Webhook.trigger("image_updated", @image)
        flash[:notice] = "Image saved."
        redirect_to action: "index"
      else
        render :edit
      end
    end

    def destroy
      @image = Image.find(params[:id])
      begin
        @image.destroy
        flash[:notice] = "Image deleted."
      rescue ActiveRecord::DeleteRestrictionError => e
        @image.errors.add(:base, e)
        render(:edit) && return
      end
      redirect_to admin_images_path
    end

    private

    def image_params
      params.require(:image).permit(:image, :name)
    end
  end
end
