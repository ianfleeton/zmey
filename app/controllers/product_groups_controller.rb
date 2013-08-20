class ProductGroupsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_product_group, only: [:show, :edit, :update, :destroy]

  def index
    @title = 'Product Groups'
    @product_groups = @w.product_groups
  end

  def show
  end

  def new
    @product_group = ProductGroup.new
  end

  def create
    @product_group = ProductGroup.new(product_group_params)
    @product_group.website_id = @w.id

    if @product_group.save
      flash[:notice] = "Successfully added new product group."
      redirect_to product_groups_path
    else
      render action: 'new'
    end
  end

  def edit
    @product_group_placement = ProductGroupPlacement.new
  end

  def update
    if @product_group.update_attributes(product_group_params)
      flash[:notice] = "Product group successfully updated."
      redirect_to product_groups_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @product_group.destroy
    redirect_to product_groups_path, notice: 'Product group deleted.'
  end

  protected

  def find_product_group
    @product_group = ProductGroup.find_by_id_and_website_id(params[:id], @w.id)
    not_found unless @product_group
  end

  def product_group_params
    params.require(:product_group).permit(:name)
  end
end
