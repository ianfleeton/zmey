class Admin::QuantityPricesController < Admin::AdminController
  before_action :set_quantity_price, only: [:edit, :destroy, :update]

  def new
    @quantity_price = QuantityPrice.new
    @quantity_price.product_id = params[:product_id]
    redirect_to(admin_products_path) && return unless product_valid?
  end

  def create
    @quantity_price = QuantityPrice.new(quantity_price_params)
    redirect_to(admin_products_path) && return unless product_valid?

    if @quantity_price.save
      flash[:notice] = "Successfully added new quantity/price rule."
      redirect_to edit_admin_product_path(@quantity_price.product)
    else
      render :new
    end
  end

  def update
    if @quantity_price.update(quantity_price_params)
      flash[:notice] = "Quantity/price rule successfully updated."
      redirect_to edit_admin_product_path(@quantity_price.product.id)
    else
      render :edit
    end
  end

  def edit
  end

  def destroy
    @quantity_price.destroy
    flash[:notice] = "Quantity/price rule deleted."
    redirect_to edit_admin_product_path(@quantity_price.product)
  end

  private

  def set_quantity_price
    @quantity_price = QuantityPrice.find(params[:id])
    redirect_to(admin_products_path) && return unless product_valid?
  end

  def product_valid?
    if Product.find_by(id: @quantity_price.product_id)
      true
    else
      flash[:notice] = "Invalid product."
      false
    end
  end

  def quantity_price_params
    params.require(:quantity_price).permit(:price, :product_id, :quantity)
  end
end
