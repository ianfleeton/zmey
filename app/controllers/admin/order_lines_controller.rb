class Admin::OrderLinesController < Admin::AdminController
  before_action :admin_required

  def update
    @order_line = OrderLine.find(params[:id])
    if @order_line.update_attributes(order_line_params)
      flash[:notice] = 'Updated.'
    else
      flash[:notice] = 'Could not update.'
    end
    redirect_to admin_order_path(@order_line.order)
  end

  private

    def order_line_params
      params.require(:order_line).permit(:feature_descriptions, :product_id, :product_name, :product_price, :product_sku, :quantity, :shipped, :tax_amount)
    end
end
