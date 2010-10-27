class ShippingZonesController < ApplicationController
  before_filter :admin_or_manager_required
  before_filter :find_shipping_zone, :only => [:edit, :update, :destroy]

  def index
    @shipping_zones = @w.shipping_zones
  end

  def new
    @shipping_zone = ShippingZone.new
  end

  def create
    @shipping_zone = ShippingZone.new(params[:shipping_zone])
    @shipping_zone.website_id = @w.id

    if @shipping_zone.save
      flash[:notice] = "Saved."
      redirect_to shipping_zones_path
    else
      render :action => "new"
    end
  end

  def update
    if @shipping_zone.update_attributes(params[:shipping_zone])
      flash[:notice] = "Saved."
      redirect_to shipping_zones_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @shipping_zone.destroy
    flash[:notice] = "Shipping zone deleted."
    redirect_to shipping_zones_path
  end

  protected

  def find_shipping_zone
    @shipping_zone = ShippingZone.find_by_id_and_website_id(params[:id], @w.id)
  end
end
