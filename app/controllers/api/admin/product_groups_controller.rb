class Api::Admin::ProductGroupsController < Api::Admin::AdminController
  def index
    @product_groups = ProductGroup.all
  end

  def show
    @product_group = ProductGroup.find_by(id: params[:id])
    render nothing: true, status: 404 unless @product_group
  end

  def create
    begin
      @product_group = ProductGroup.new(product_group_params)
    rescue ActionController::ParameterMissing
      @product_group = ProductGroup.new
    end

    if !@product_group.save
      render json: @product_group.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    ProductGroup.delete_all
    ProductGroupPlacement.delete_all
    render nothing: :true, status: 204
  end

  private

    def product_group_params
      params.require(:product_group).permit(:name, :location)
    end
end
