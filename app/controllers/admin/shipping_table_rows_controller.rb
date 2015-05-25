class Admin::ShippingTableRowsController < Admin::AdminController
  before_action :set_shipping_table_row, only: [:edit, :update, :destroy]

  def new
    @shipping_table_row = ShippingTableRow.new
    @shipping_table_row.shipping_class_id = params[:shipping_class_id]
  end

  def create
    @shipping_table_row = ShippingTableRow.new(shipping_table_row_params)

    if @shipping_table_row.save
      flash[:notice] = "Saved."
      redirect_to edit_admin_shipping_class_path(@shipping_table_row.shipping_class)
    else
      render :new
    end
  end

  def destroy
    @shipping_table_row.destroy
    flash[:notice] = "Shipping rule deleted."
    redirect_to edit_admin_shipping_class_path(@shipping_table_row.shipping_class)
  end

  private

    def set_shipping_table_row
      @shipping_table_row = ShippingTableRow.find_by(id: params[:id])
    end

    def shipping_table_row_params
      params.require(:shipping_table_row).permit(:amount, :shipping_class_id, :trigger_value)
    end
end
