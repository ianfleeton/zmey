class OrderLinesController < ApplicationController
  before_filter :admin_required

  def update
    @order_line = OrderLine.find(params[:id])
    if @order_line.update_attributes(order_line_params)
      flash[:notice] = 'Updated.'
    else
      flash[:notice] = 'Could not update.'
    end
    redirect_to @order_line.order
  end

  private

    def order_line_params
      params.require(:order_line).permit(:feature_descriptions, :line_total, :product_id, :product_name, :product_price, :product_sku, :quantity, :tax_amount)
    end
end
