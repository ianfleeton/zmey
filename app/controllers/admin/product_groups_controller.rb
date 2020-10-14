class Admin::ProductGroupsController < Admin::AdminController
  before_action :set_product_group, only: [:show, :edit, :update, :destroy]

  def index
    @title = "Product Groups"
    @product_groups = ProductGroup.order(:name)
  end

  def show
  end

  def new
    @product_group = ProductGroup.new
  end

  def create
    @product_group = ProductGroup.new(product_group_params)

    if @product_group.save
      flash[:notice] = "Successfully added new product group."
      redirect_to admin_product_groups_path
    else
      render :new
    end
  end

  def edit
    @product_group_placement = ProductGroupPlacement.new
  end

  def update
    if @product_group.update(product_group_params)
      flash[:notice] = "Product group successfully updated."
      redirect_to admin_product_groups_path
    else
      render :edit
    end
  end

  def destroy
    @product_group.destroy
    redirect_to admin_product_groups_path, notice: "Product group deleted."
  end

  private

  def set_product_group
    @product_group = ProductGroup.find_by(id: params[:id])
    not_found unless @product_group
  end

  def product_group_params
    params.require(:product_group).permit(:location_id, :name)
  end
end
