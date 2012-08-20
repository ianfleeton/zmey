class ProductGroupPlacementsController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_product_group_placement, except: [:create]

  def create
    @product_group_placement = ProductGroupPlacement.new(params[:product_group_placement])
    if @product_group_placement.save
      flash[:notice] = "Product successfully added to group."
    else
      flash[:notice] = 'Product not added.'
    end
    redirect_to edit_product_group_path @product_group_placement.product_group
  end

  def destroy
    product_group = @product_group_placement.product_group
    @product_group_placement.destroy
    flash[:notice] = 'Product removed from group.'

    respond_to do |format|
      format.html { redirect_to edit_product_group_path(product_group) }
      format.xml  { head :ok }
    end
  end

  protected

  def find_product_group_placement
    @product_group_placement = ProductGroupPlacement.find(params[:id])
  end
end
