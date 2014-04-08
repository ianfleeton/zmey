class Admin::AdditionalProductsController < Admin::AdminController
  before_action :find_additional_product, only: [:edit, :destroy, :update]

  def new
    @additional_product = AdditionalProduct.new
    @additional_product.product_id = params[:product_id]
    redirect_to admin_products_path and return unless product_valid?
  end

  def create
    @additional_product = AdditionalProduct.new(additional_product_params)
    redirect_to admin_products_path and return unless product_valid?

    if @additional_product.save
      flash[:notice] = "Successfully added new additional product."
      redirect_to edit_admin_product_path(@additional_product.product)
    else
      render :new
    end
  end

  def update
    if @additional_product.update_attributes(additional_product_params)
      flash[:notice] = "Additional product successfully updated."
      redirect_to edit_admin_product_path(@additional_product.product)
    else
      render :edit
    end
  end

  def edit
  end

  def destroy
    @additional_product.destroy
    flash[:notice] = "Additional product deleted."
    redirect_to edit_admin_product_path(@additional_product.product)
  end

  protected

  def find_additional_product
    @additional_product = AdditionalProduct.find(params[:id])
    redirect_to admin_products_path and return unless product_valid?
  end

  def product_valid?
    if find_product
      true
    else
      flash[:notice] = 'Invalid product.'
      false
    end
  end

  def find_product
    Product.find_by(id: @additional_product.product_id, website_id: @w.id)
  end

  def additional_product_params
    params.require(:additional_product).permit(:additional_product_id, :product_id, :selected_by_default)
  end
end
