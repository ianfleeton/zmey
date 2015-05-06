class Admin::ShipmentsController < Admin::AdminController
  def new
    @order = Order.find(params[:order_id])
  end
end
