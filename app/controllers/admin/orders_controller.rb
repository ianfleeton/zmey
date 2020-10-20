module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:show, :edit, :update, :destroy, :mark_processed, :mark_unprocessed, :record_sales_conversion]

    def index
      @orders = if params[:user_id]
        User.find(params[:user_id]).orders.paginate(page: params[:page], per_page: 50)
      else
        Order.order(created_at: :desc).where(search_conditions).paginate(page: params[:page], per_page: 250)
      end
    end

    def show
    end

    def new
      @order = Order.new
    end

    def create
      @order = Order.new(order_params)
      @order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT

      if @order.save!
        redirect_to admin_orders_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @order.locked?
        @order.update(locked_order_params)
      else
        @order.update(order_params)
        if params[:order_line_quantity].present?
          add_order_lines
          update_order_lines
        end
      end
      redirect_to edit_admin_order_path(@order)
    end

    def purge_old_unpaid
      Order.purge_old_unpaid
      redirect_to admin_orders_path, notice: "Old and unpaid orders purged."
    end

    def destroy
      @order.destroy
      redirect_to admin_orders_path, notice: "Order deleted."
    end

    def search_products
      @products = Product.admin_search(params[:query])
      render layout: false
    end

    def mark_processed
      order_processed!(Time.zone.now)
      redirect_to edit_admin_order_path(@order), notice: I18n.t("controllers.admin.orders.mark_processed.marked")
    end

    def mark_unprocessed
      order_processed!(nil)
      redirect_to edit_admin_order_path(@order), notice: I18n.t("controllers.admin.orders.mark_unprocessed.marked")
    end

    def record_sales_conversion
    end

    protected

    def order_params
      params.require(:order).permit(
        :billing_address_line_1,
        :billing_address_line_2,
        :billing_company,
        :billing_country_id,
        :billing_county,
        :billing_full_name,
        :billing_phone_number,
        :billing_postcode,
        :billing_town_city,
        :delivery_address_line_1,
        :delivery_address_line_2,
        :delivery_company,
        :delivery_country_id,
        :delivery_county,
        :delivery_full_name,
        :delivery_instructions,
        :delivery_phone_number,
        :delivery_postcode,
        :delivery_town_city,
        :email_address,
        :po_number,
        :shipping_amount,
        :shipped_at,
        :shipping_method,
        :shipping_tax_amount,
        :shipping_tracking_number
      )
    end

    def locked_order_params
      params.require(:order).permit(
        :shipped_at,
        :shipping_tracking_number
      )
    end

    # get specific order
    def set_order
      @order = Order.find_by(id: params[:id])
      if @order.nil?
        redirect_to orders_path, notice: "Cannot find order."
      end
    end

    # Add new order lines to the order.
    def add_order_lines
      new_order_line_keys.each { |k| add_order_line(k) }
    end

    # Adds a single new order line to @order.
    def add_order_line(key)
      order_line = OrderLine.new(order: @order)
      update_order_line(order_line, key)
      order_line.save
    end

    # Returns an array of new order line keys (those which are negative).
    def new_order_line_keys
      params[:order_line_quantity].keys.select { |k| k.to_i < 0 }
    end

    def update_order_lines
      params[:order_line_quantity].each_pair do |id, _on|
        if (order_line = OrderLine.find_by(id: id, order_id: @order.id))
          update_order_line(order_line, id)
        end
      end
    end

    def update_order_line(order_line, key)
      updater = ::Orders::OrderLineUpdater.new(
        administrator: "Unknown",
        order_line: order_line,
        feature_descriptions: params[:order_line_feature_descriptions][key],
        product_brand: params[:order_line_product_brand][key],
        product_id: params[:order_line_product_id][key],
        product_name: params[:order_line_product_name][key],
        product_price: params[:order_line_product_price][key],
        product_sku: params[:order_line_product_sku][key],
        product_weight: params[:order_line_product_weight][key],
        quantity: params[:order_line_quantity][key],
        tax_percentage: params[:order_line_tax_percentage][key]
      )
      updater.save
    end

    # Calculates the tax amount for <tt>order_line</tt> when the tax rate is
    # <tt>percentage</tt>%.
    def tax_amount(order_line, percentage)
      percentage.to_f / 100.0 * order_line.line_total_net
    end

    # Returns an array of search conditions for filtering orders based on
    # params.
    def search_conditions
      conditions = ["1 = 1"]

      partial_match_search_keys.each do |key|
        if params[key].present?
          conditions[0] += " AND #{key} LIKE ?"
          conditions << "%#{params[key]}%"
        end
      end

      if params[:order_number].present?
        conditions[0] += " AND order_number = ?"
        conditions << params[:order_number]
      end

      conditions
    end

    # Returns an array of keys that can be used for partial match searching.
    def partial_match_search_keys
      [
        :billing_company,
        :billing_full_name,
        :billing_postcode,
        :delivery_postcode,
        :email_address
      ]
    end

    def order_processed!(time)
      @order.processed_at = time
      @order.save
    end
  end
end
