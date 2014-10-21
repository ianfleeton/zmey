class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [:show, :edit, :destroy]

  def index
    if params[:user_id]
      @orders = User.find(params[:user_id]).orders.where(website_id: website.id).paginate(page: params[:page], per_page: 50)
    else
      @orders = website.orders.paginate(page: params[:page], per_page: 250)
    end
  end

  def show; end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.status = Order::WAITING_FOR_PAYMENT
    @order.website = website

    if @order.save
      redirect_to admin_orders_path
    else
      render :new
    end
  end

  def edit; end

  def purge_old_unpaid
    Order.purge_old_unpaid
    redirect_to admin_orders_path, notice: 'Old and unpaid orders purged.'
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: 'Order deleted.'
  end

  protected

    def order_params
      params.require(:order).permit(
        :delivery_address_line_1,
        :delivery_country_id,
        :delivery_postcode,
        :delivery_town_city,
        :email_address,
      )
    end

    # get specific order
    def set_order
      @order = Order.find_by(id: params[:id], website_id: website.id)
      if @order.nil?
        redirect_to orders_path, notice: 'Cannot find order.'
      end
    end
end
