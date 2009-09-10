class FeaturesController < ApplicationController
  before_filter :admin_required
  def new
    @feature = Feature.new
    @feature.product_id = params[:product_id]
    redirect_to products_path and return unless product_valid?
    @feature.required = true
  end
  
  def create
    @feature = Feature.new(params[:feature])
    redirect_to products_path and return unless product_valid?

    if @feature.save
      flash[:notice] = "Successfully added new feature."
      redirect_to product_path(@feature.product)
    else
      render :action => "new"
    end
  end
  
  def edit
    @feature = Feature.find(params[:id])
  end
  
  protected
  
  def product_valid?
    if Product.find_by_id_and_website_id(@feature.product_id, @w.id)
      true
    else
      flash[:notice] = 'Invalid product.'
      false
    end
  end
end
