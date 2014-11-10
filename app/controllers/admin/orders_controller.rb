class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

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
    @order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
    @order.website = website

    if @order.save
      redirect_to admin_orders_path
    else
      render :new
    end
  end

  def edit; end

  def update
    update_order_lines if params[:order_line_quantity]
    redirect_to edit_admin_order_path(@order)
  end

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
        :billing_address_line_1,
        :billing_country_id,
        :billing_postcode,
        :billing_town_city,
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

    def update_order_lines
      params[:order_line_quantity].each_key { |id| update_order_line(id) }
    end

    def update_order_line(id)
      if order_line = OrderLine.find_by(id: id, order_id: @order.id)
        orig_tax_percentage      = order_line.tax_percentage
        order_line.quantity      = params[:order_line_quantity][id]
        order_line.product_name  = params[:order_line_product_name][id]

        # Prevent AR change being recorded unnecessarily.
        if order_line.product_price != params[:order_line_product_price][id].to_f
          order_line.product_price = params[:order_line_product_price][id].to_f
        end

        # Use three decimal places and ignore changes to a higher precision.
        tax_changed = (orig_tax_percentage.round(3) != params[:order_line_tax_percentage][id].to_f.round(3))

        if order_line.changed? || tax_changed
          order_line.tax_amount = params[:order_line_tax_percentage][id].to_f / 100.0 * order_line.line_total_net
        end

        order_line.save
      end
    end
end
