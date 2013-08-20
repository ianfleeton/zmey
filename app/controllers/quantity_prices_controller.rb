class QuantityPricesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_quantity_price, only: [:edit, :destroy, :update]

  def new
    @quantity_price = QuantityPrice.new
    @quantity_price.product_id = params[:product_id]
    redirect_to products_path and return unless product_valid?
  end
  
  def create
    @quantity_price = QuantityPrice.new(quantity_price_params)
    redirect_to products_path and return unless product_valid?

    if @quantity_price.save
      flash[:notice] = "Successfully added new quantity/price rule."
      redirect_to edit_product_path(@quantity_price.product)
    else
      render action: 'new'
    end
  end
  
  def update
    if @quantity_price.update_attributes(quantity_price_params)
      flash[:notice] = "Quantity/price rule successfully updated."
      redirect_to edit_product_path(@quantity_price.product.id)
    else
      render action: 'edit'
    end
  end
  
  def edit
  end
  
  def destroy
    @quantity_price.destroy
    flash[:notice] = "Quantity/price rule deleted."
    redirect_to edit_product_path(@quantity_price.product)
  end
  
  protected
  
  def find_quantity_price
    @quantity_price = QuantityPrice.find(params[:id])
    redirect_to products_path and return unless product_valid?
  end
  
  def product_valid?
    if Product.find_by_id_and_website_id(@quantity_price.product_id, @w.id)
      true
    else
      flash[:notice] = 'Invalid product.'
      false
    end
  end

  def quantity_price_params
    params.require(:quantity_price).permit(:price, :product_id, :quantity)
  end
end
