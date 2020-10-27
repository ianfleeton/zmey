class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :invoice]
  before_action :require_order, only: [:receipt]
  before_action :user_required, only: [:index, :show, :invoice]

  layout "basket_checkout", only: [:receipt, :select_payment_method]

  def index
    @orders = current_user.orders
  end

  def receipt
    redirect_to controller: "basket", action: "index" unless can_show_receipt?(@order)
  end

  def show
    if can_access_order?
      render :receipt
    else
      redirect_to :root, notice: "You do not have permission to view that order."
    end
  end

  def invoice
    redirect_to(new_session_path) && return unless can_access_order?
    redirect_to(orders_path) && return unless @order.fully_shipped?
    respond_to do |format|
      format.pdf do
        send_invoice_pdf(@order)
      end
      format.html do
        render layout: "invoice"
      end
    end
  end

  protected

  def can_access_order?
    admin? || @current_user.id == @order.user_id
  end

  # get valid order from current session or send user back to their basket
  def require_order
    @order = Order.find_by(id: session[:order_id])
    if @order.nil?
      redirect_to({controller: "basket", action: "index"},
        notice: "We couldn't find an order for you.")
    end
  end

  # get specific order
  def find_order
    @order = Order.find_by(id: params[:id])
    if @order.nil?
      redirect_to orders_path, notice: "Cannot find order."
    end
  end

  def can_show_receipt?(order)
    order.payment_received? || order.status == Enums::PaymentStatus::PAYMENT_ON_ACCOUNT || order.status == Enums::PaymentStatus::QUOTE
  end

  def send_invoice_pdf(order)
    invoice = PDF::Invoice.new(order)
    invoice.generate
    send_file(invoice.filename)
  end
end
