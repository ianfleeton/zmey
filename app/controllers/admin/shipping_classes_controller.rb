class Admin::ShippingClassesController < Admin::AdminController
  before_action :set_shipping_class, only: [:edit, :update, :destroy]

  def index
    @shipping_classes = ShippingClass.order(:name)
  end

  def new
    @shipping_class = ShippingClass.new
  end

  def create
    @shipping_class = ShippingClass.new(shipping_class_params)

    if @shipping_class.save
      redirect_to admin_shipping_classes_path, notice: "Saved."
    else
      render :new
    end
  end

  def update
    if @shipping_class.update(shipping_class_params)
      redirect_to admin_shipping_classes_path, notice: "Saved."
    else
      render :edit
    end
  end

  def destroy
    @shipping_class.destroy
    flash[:notice] = "Shipping class deleted."
    redirect_to admin_shipping_classes_path
  end

  protected

  def set_shipping_class
    @shipping_class = ShippingClass.find(params[:id])
  end

  def shipping_class_params
    params.require(:shipping_class).permit(
      :allow_oversize,
      :charge_vat,
      :invalid_over_highest_trigger,
      :name,
      :requires_delivery_address,
      :shipping_zone_id,
      :table_rate_method
    )
  end
end
