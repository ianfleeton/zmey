class Admin::ProductImagesController < Admin::AdminController
  def create
    product_image = ProductImage.new(product_image_params)

    flash[:notice] = if product_image.save
      t("controllers.admin.product_images.create.added")
    else
      t("controllers.admin.product_images.create.not_added")
    end
    redirect_to edit_admin_product_path(product_image.product)
  end

  def destroy
    @product_image = ProductImage.find(params[:id])

    @product_image.destroy

    redirect_to edit_admin_product_path(@product_image.product), notice: t("controllers.admin.product_images.destroy.removed")
  end

  private

  def product_image_params
    params.require(:product_image).permit(:image_id, :product_id)
  end
end
