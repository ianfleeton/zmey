class Admin::OrdersController < Admin::AdminController
  before_action :find_order, only: [:show, :destroy]

  def index
    if params[:user_id]
      @orders = User.find(params[:user_id]).orders.where(website_id: website.id).paginate(page: params[:page], per_page: 50)
    else
      @orders = website.orders.paginate(page: params[:page], per_page: 250)
    end
  end

  def show; end

  def purge_old_unpaid
    Order.purge_old_unpaid
    redirect_to admin_orders_path, notice: 'Old and unpaid orders purged.'
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: 'Order deleted.'
  end

  protected

  # get specific order
  def find_order
    @order = Order.find_by(id: params[:id], website_id: website.id)
    if @order.nil?
      redirect_to orders_path, notice: 'Cannot find order.'
    end
  end
end
