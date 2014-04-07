class Admin::FeaturesController < Admin::AdminController
  before_action :set_feature, only: [:edit, :destroy, :update]

  def new
    @feature = Feature.new
    @feature.product_id = params[:product_id]
    @feature.component_id = params[:component_id]
    redirect_to products_path and return unless product_valid?
    @feature.required = true
  end

  def create
    @feature = Feature.new(feature_params)
    redirect_to admin_products_path and return unless product_valid?

    if @feature.save
      flash[:notice] = "Successfully added new feature."
      redirect_to edit_admin_feature_path(@feature)
    else
      render :new
    end
  end

  def update
    if @feature.update_attributes(feature_params)
      flash[:notice] = "Feature successfully updated."
      if @feature.component
        redirect_to edit_component_path(@feature.component)
      else
        redirect_to edit_admin_product_path(@feature.product)
      end
    else
      render :edit
    end
  end

  def edit
  end

  def destroy
    @feature.destroy
    redirect_to edit_admin_product_path(@feature.product), notice: 'Feature deleted.'
  end

  protected

    def set_feature
      @feature = Feature.find(params[:id])
      redirect_to admin_products_path and return unless product_valid?
    end

    def product_valid?
      if Product.find_by(id: @feature.product_id, website_id: @w.id)
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
