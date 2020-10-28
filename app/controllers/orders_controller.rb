# Controller for customer/order interactions.
class OrdersController < ApplicationController
  before_action :find_order, only: %i[show invoice track]
  before_action :require_order, only: %i[receipt request_shipping_quote]
  before_action :user_required, only: %i[index show invoice]

  layout "basket_checkout", only: [:receipt]

  def index
    @orders = current_user.orders
  end

  def receipt
    return if can_show_receipt?(@order)

    redirect_to controller: "basket", action: "index"
  end

  def show
    return if can_access_order?

    redirect_to :root, notice: I18n.t("controllers.orders.show.no_permission")
  end

  def invoice
    ensure_invoice_access
    ensure_order_is_invoice

    return if performed?

    respond_to do |format|
      format.pdf { send_invoice_pdf(@order) }
      format.html do
        @subject = "#{@order.paperwork_type.titleize} # " \
          "#{@order.order_number} | #{website}"
        render layout: "invoice"
      end
    end
  end

  def ensure_invoice_access
    redirect_to new_customer_session_path unless can_access_order?
  end

  def ensure_order_is_invoice
    redirect_to orders_path unless @order.invoice?
  end

  def opt_in
    if (order = current_order) && (user = order.user)
      user.update_opt_in(params[:opt_in] == "1")
      user.save
    end
    head :ok
  end

  def request_shipping_quote
    @order.status = Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE
    @order.save

    redirect_to(
      receipt_orders_path,
      notice: I18n.t("controllers.orders.request_shipping_quote.what_next")
    )
  end

  # Provides shipment tracking information for an order.
  def track
    if @order.token != params[:t]
      flash[:alert] = "That link is invalid."
      redirect_to root_path
      return
    end

    @shipments = @order.shipments.where.not(shipped_at: nil)
  end

  protected

  def token_valid?
    @order && @order.email_confirmation_token.present? &&
      @order.email_confirmation_token == @token
  end

  def token_current?
    @order.payments.last.updated_at > Time.current - Order::OFFLINE_CONFIRMATION_TOKEN_EXPIRY
  end

  def can_access_order?
    current_user.id == @order.user_id
  end

  # get valid order from current session or send user back to their basket
  def require_order
    @order = current_order

    return if @order

    redirect_to(
      {controller: "basket", action: "index"},
      notice: "We couldn't find an order for you."
    )
  end

  # Get order in cookie.
  def current_order
    Order.current(cookies)
  end

  # get specific order
  def find_order
    @order = Order.find_by(id: params[:id])

    redirect_to orders_path, notice: "Cannot find order." unless @order
  end

  def can_show_receipt?(order)
    order.payment_received? ||
      order.payment_on_account? ||
      order.quote? ||
      order.pay_by_phone? ||
      order.needs_shipping_quote?
  end

  def send_invoice_pdf(order)
    invoice = PDF::Invoice.new(order)
    invoice.generate
    send_file(invoice.filename)
  end
end
