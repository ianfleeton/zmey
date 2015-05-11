class Api::Admin::ProductPlacementsController < Api::Admin::AdminController
  def create
    @product_placement = ProductPlacement.new(product_placement_params)
    if Product.exists?(id: params[:product_placement][:product_id]) && Page.exists?(id: params[:product_placement][:page_id])
      unless @product_placement.save
        render json: @product_placement.errors, status: :unprocessable_entity
      end
    else
      @product_placement.errors.add(:base, 'Page or product does not exist.')
      render json: @product_placement.errors, status: :unprocessable_entity
    end
  end

  def delete_all
    ProductPlacement.delete_all
    render nothing: :true, status: 204
  end

  private

    def product_placement_params
      params.require(:product_placement).permit(:page_id, :product_id)
    end
end
