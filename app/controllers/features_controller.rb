class FeaturesController < ApplicationController
  layout 'admin'
  before_action :admin_or_manager_required
  before_action :find_feature, only: [:edit, :destroy, :update]

  def new
    @feature = Feature.new
    @feature.product_id = params[:product_id]
    @feature.component_id = params[:component_id]
    redirect_to products_path and return unless product_valid?
    @feature.required = true
  end
  
  def create
    @feature = Feature.new(feature_params)
    redirect_to products_path and return unless product_valid?

    if @feature.save
      flash[:notice] = "Successfully added new feature."
      redirect_to edit_feature_path(@feature)
    else
      render action: 'new'
    end
  end
  
  def update
    if @feature.update_attributes(feature_params)
      flash[:notice] = "Feature successfully updated."
      if @feature.component
        redirect_to edit_component_path(@feature.component)
      else
        redirect_to edit_product_path(@feature.product)
      end
    else
      render action: 'edit'
    end
  end

  def edit
  end
  
  def destroy
    @feature.destroy
    redirect_to edit_product_path(@feature.product), notice: 'Feature deleted.'
  end
  
  protected
  
  def find_feature
    @feature = Feature.find(params[:id])
    redirect_to products_path and return unless product_valid?
  end
  
  def product_valid?
    if Product.find_by_id_and_website_id(@feature.product_id, @w.id)
      true
    else
      flash[:notice] = 'Invalid product.'
      false
    end
  end

  def feature_params
    params.require(:feature).permit(:component_id, :name, :product_id, :required, :ui_type)
  end
end
