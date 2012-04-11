class ShippingTableRowsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_shipping_table_row, :only => [:edit, :update, :destroy]

  def new
    @shipping_table_row = ShippingTableRow.new
    @shipping_table_row.shipping_class_id = params[:shipping_class_id]
  end

  def create
    @shipping_table_row = ShippingTableRow.new(params[:shipping_table_row])

    if @shipping_table_row.save
      flash[:notice] = "Saved."
      redirect_to edit_shipping_class_path(@shipping_table_row.shipping_class)
    else
      render :action => "new"
    end
  end

  def destroy
    @shipping_table_row.destroy
    flash[:notice] = "Shipping rule deleted."
    redirect_to edit_shipping_class_path(@shipping_table_row.shipping_class)
  end

  protected

  def find_shipping_table_row
    @shipping_table_row = ShippingTableRow.find_by_id(params[:id])
  end
end
