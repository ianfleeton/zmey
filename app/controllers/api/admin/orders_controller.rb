class Api::Admin::OrdersController < Api::Admin::AdminController
  def index
    @orders = website.orders
  end

  def show
    @order = Order.find_by(id: params[:id], website: website)
    render nothing: true, status: 404 unless @order
  end
end
