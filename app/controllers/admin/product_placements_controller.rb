class Admin::ProductPlacementsController < Admin::AdminController
  before_action :set_product_placement, except: [:create]
  # TODO: restrict by website
  
  def create
    @product_placement = ProductPlacement.new(product_placement_params)
    if @product_placement.save
      flash[:notice] = "Product successfully placed in page."
      redirect_to edit_admin_page_path(@product_placement.page)
    else
      render :new
    end
  end

  def destroy
    @product_placement.destroy
    redirect_to edit_admin_page_path(@product_placement.page), notice: 'Product removed from page.'
  end

  def move_up
    @product_placement.move_higher
    moved
  end

  def move_down
    @product_placement.move_lower
    moved
  end

  private

    def set_product_placement
      @product_placement = ProductPlacement.find(params[:id])
    end

    def moved
      flash[:notice] = "Moved."
      redirect_to edit_admin_page_path(@product_placement.page)
    end

    def product_placement_params
      params.require(:product_placement).permit(:page_id, :position, :product_id)
    end
end
