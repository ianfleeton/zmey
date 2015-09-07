class Api::Admin::ProductGroupsController < Api::Admin::AdminController
  def show
    @product_group = ProductGroup.find_by(id: params[:id])
    render nothing: true, status: 404 unless @product_group
  end
end
