class Api::Admin::ProductGroupsController < Api::Admin::AdminController
  def index
    @product_groups = ProductGroup.all
  end

  def show
    @product_group = ProductGroup.find_by(id: params[:id])
    render nothing: true, status: 404 unless @product_group
  end
end
