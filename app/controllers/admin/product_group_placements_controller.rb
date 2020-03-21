class Admin::ProductGroupPlacementsController < Admin::AdminController
  before_action :find_product_group_placement, except: [:create]

  def create
    @product_group_placement = ProductGroupPlacement.new(product_group_placement_params)
    flash[:notice] = if @product_group_placement.save
      "Product successfully added to group."
    else
      "Product not added."
    end
    redirect_to edit_admin_product_group_path(@product_group_placement.product_group)
  end

  def destroy
    product_group = @product_group_placement.product_group
    @product_group_placement.destroy
    flash[:notice] = "Product removed from group."
    redirect_to edit_admin_product_group_path(product_group)
  end

  protected

  def find_product_group_placement
    @product_group_placement = ProductGroupPlacement.find(params[:id])
  end

  def product_group_placement_params
    params.require(:product_group_placement).permit(:product_group_id, :product_id)
  end
end
