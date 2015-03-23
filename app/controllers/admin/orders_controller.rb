class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    if params[:user_id]
      @orders = User.find(params[:user_id]).orders.paginate(page: params[:page], per_page: 50)
    else
      @orders = Order.order(created_at: :desc).paginate(page: params[:page], per_page: 250)
    end
  end

  def show; end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT

    if @order.save
      redirect_to admin_orders_path
    else
      render :new
    end
  end

  def edit; end

  def update
    @order.update_attributes(order_params)
    if params[:order_line_quantity]
      add_order_lines
      update_order_lines
    end
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
        :billing_address_line_2,
        :billing_country_id,
        :billing_county,
        :billing_postcode,
        :billing_town_city,
        :delivery_address_line_1,
        :delivery_address_line_2,
        :delivery_country_id,
        :delivery_county,
        :delivery_postcode,
        :delivery_town_city,
        :email_address,
      )
    end

    # get specific order
    def set_order
      @order = Order.find_by(id: params[:id])
      if @order.nil?
        redirect_to orders_path, notice: 'Cannot find order.'
      end
    end

    # Add new order lines to the order.
    def add_order_lines
      new_order_line_keys.each { |k| add_order_line(k) }
    end

    # Adds a single new order line to @order.
    def add_order_line(key)
      order_line = OrderLine.new(
        order: @order,
        product_name: params[:order_line_product_name][key],
        product_price: params[:order_line_product_price][key],
        product_weight: params[:order_line_product_weight][key],
        quantity: params[:order_line_quantity][key],
      )
      order_line.tax_amount = tax_amount(order_line, params[:order_line_tax_percentage][key])
      order_line.save
    end

    # Returns an array of new order line keys (those which are negative).
    def new_order_line_keys
      params[:order_line_quantity].keys.select { |k| k.to_i < 0 }
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
          order_line.tax_amount = tax_amount(order_line, params[:order_line_tax_percentage][id])
        end

        order_line.save
      end
    end

    # Calculates the tax amount for <tt>order_line</tt> when the tax rate is
    # <tt>percentage</tt>%.
    def tax_amount(order_line, percentage)
      percentage.to_f / 100.0 * order_line.line_total_net
    end
end
