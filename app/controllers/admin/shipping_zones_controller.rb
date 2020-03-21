class Admin::ShippingZonesController < Admin::AdminController
  before_action :set_shipping_zone, only: [:edit, :update, :destroy]

  def index
    @shipping_zones = ShippingZone.order(:name)
  end

  def new
    @shipping_zone = ShippingZone.new
  end

  def create
    @shipping_zone = ShippingZone.new(shipping_zone_params)

    if @shipping_zone.save
      redirect_to admin_shipping_zones_path, notice: "Saved."
    else
      render :new
    end
  end

  def update
    if @shipping_zone.update_attributes(shipping_zone_params)
      redirect_to admin_shipping_zones_path, notice: "Saved."
    else
      render :edit
    end
  end

  def destroy
    @shipping_zone.destroy
    redirect_to admin_shipping_zones_path, notice: "Shipping zone deleted."
  end

  protected

  def set_shipping_zone
    @shipping_zone = ShippingZone.find_by(id: params[:id])
  end

  def shipping_zone_params
    params.require(:shipping_zone).permit(:default_shipping_class_id, :name)
  end
end
