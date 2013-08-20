class ShippingZonesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_shipping_zone, only: [:edit, :update, :destroy]

  def index
    @shipping_zones = @w.shipping_zones
  end

  def new
    @shipping_zone = ShippingZone.new
  end

  def create
    @shipping_zone = ShippingZone.new(shipping_zone_params)
    @shipping_zone.website_id = @w.id

    if @shipping_zone.save
      redirect_to shipping_zones_path, notice: 'Saved.'
    else
      render action: 'new'
    end
  end

  def update
    if @shipping_zone.update_attributes(shipping_zone_params)
      redirect_to shipping_zones_path, notice: 'Saved.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @shipping_zone.destroy
    redirect_to shipping_zones_path, notice: 'Shipping zone deleted.'
  end

  protected

  def find_shipping_zone
    @shipping_zone = ShippingZone.find_by_id_and_website_id(params[:id], @w.id)
  end

  def shipping_zone_params
    params.require(:shipping_zone).permit(:name)
  end
end
