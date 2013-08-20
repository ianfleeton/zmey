class ShippingClassesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_shipping_class, only: [:edit, :update, :destroy]

  def index
    @shipping_classes = @w.shipping_classes
  end

  def new
    @shipping_class = ShippingClass.new
  end

  def create
    @shipping_class = ShippingClass.new(shipping_class_params)

    if @shipping_class.save
      redirect_to shipping_classes_path, notice: 'Saved.'
    else
      render action: 'new'
    end
  end

  def update
    if @shipping_class.update_attributes(shipping_class_params)
      redirect_to shipping_classes_path, notice: 'Saved.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @shipping_class.destroy
    flash[:notice] = 'Shipping class deleted.'
    redirect_to shipping_classes_path
  end

  protected

  def find_shipping_class
    @shipping_class = ShippingClass.find(params[:id])
  end

  def shipping_class_params
    params.require(:shipping_class).permit(:name, :shipping_zone_id)
  end
end
