class ProductGroupPlacementsController < ApplicationController
  before_filter :admin_required
  before_filter :find_product_group_placement, :except => [:create]

  def create
    @product_group_placement = ProductGroupPlacement.new(params[:product_group_placement])
    if @product_group_placement.save
      flash[:notice] = "Product successfully added to group."
      redirect_to edit_product_group_path @product_group_placement.product_group
    else
      flash[:notice] = 'Product not added.'
      redirect_to :controller => 'product_groups', :action => 'edit', :id => @product_group_placement.product_group_id
    end
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
