class ProductGroupsController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_product_group, :only => [:show, :edit, :update]

  def index
    @title = 'Product Groups'
    @product_groups = ProductGroup.all(:conditions => {:website_id => @w.id}, :order => :name)
  end

  def show
  end

  def new
    @product_group = ProductGroup.new
  end

  def create
    @product_group = ProductGroup.new(params[:product_group])
    @product_group.website_id = @w.id

    if @product_group.save
      flash[:notice] = "Successfully added new product group."
      redirect_to product_groups_path
    else
      render :action => "new"
    end
  end

  def edit
    @product_group_placement = ProductGroupPlacement.new
  end

  def update
    if @product_group.update_attributes(params[:product_group])
      flash[:notice] = "Product group successfully updated."
      redirect_to product_groups_path
    else
      render :action => "edit"
    end
  end

  protected

  def find_product_group
    @product_group = ProductGroup.find_by_id_and_website_id(params[:id], @w.id)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found" if @product_group.nil?
  end
end
