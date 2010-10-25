class ShippingClassesController < ApplicationController
  before_filter :find_shipping_class, :only => [:edit, :update, :destroy]

  def index
    @shipping_classes = @w.shipping_classes
  end

  def new
    @shipping_class = ShippingClass.new
  end

  def create
    @shipping_class = ShippingClass.new(params[:shipping_class])

    if @shipping_class.save
      flash[:notice] = "Saved."
      redirect_to shipping_classes_path
    else
      render :action => "new"
    end
  end

  def update
    if @shipping_class.update_attributes(params[:shipping_class])
      flash[:notice] = "Saved."
      redirect_to shipping_classes_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @shipping_class.destroy
    flash[:notice] = "Shipping class deleted."
    redirect_to shipping_classes_path
  end

  protected

  def find_shipping_class
    @shipping_class = ShippingClass.find(params[:id])
  end
end
