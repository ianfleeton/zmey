class ProductPlacementsController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_product_placement, except: [:create]
  # TODO: restrict by website
  
  def create
    @product_placement = ProductPlacement.new(params[:product_placement])
    if @product_placement.save
      flash[:notice] = "Product successfully placed in page."
      redirect_to edit_page_path(@product_placement.page)
    else
      render :action => "new"
    end
  end

  def destroy
    page = @product_placement.page
    @product_placement.destroy
    redirect_to edit_page_path(@product_placement.page), notice: 'Product removed from page.'
  end

  def move_up
    @product_placement.move_higher
    moved
  end

  def move_down
    @product_placement.move_lower
    moved
  end

  protected

  def find_product_placement
    @product_placement = ProductPlacement.find(params[:id])
  end

  def moved
    flash[:notice] = "Moved."
    redirect_to edit_page_path(@product_placement.page)
  end
end
