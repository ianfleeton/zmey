class ProductPlacementsController < ApplicationController
  before_filter :admin_required
  
  def create
    @product_placement = ProductPlacement.new(params[:product_placement])
    if @product_placement.save
      flash[:notice] = "Product successfully placed in page."
      redirect_to page_path @product_placement.page
    else
      render :action => "new"
    end
  end

  def destroy
    @product_placement = ProductPlacement.find(params[:id])
    page = @product_placement.page
    @product_placement.destroy
    flash[:notice] = 'Product removed from page.'

    respond_to do |format|
      format.html { redirect_to page_path(page) }
      format.xml  { head :ok }
    end
  end
end
