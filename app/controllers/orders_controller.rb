class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :invoice]
  before_action :require_order, only: [:select_payment_method, :receipt]
  before_action :user_required, only: [:index, :show, :invoice]

  def index
    @orders = current_user.orders
  end

  def select_payment_method
    prepare_cardsave if @w.cardsave_active?
  end

  def receipt
    redirect_to controller: 'basket', action: 'index' and return unless (@order.payment_received? or @order.status==Order::PAYMENT_ON_ACCOUNT)
    @google_ecommerce_tracking = true
  end
  
  def show
    if can_access_order?
      render action: 'receipt'
    else
      redirect_to :root, notice: 'You do not have permission to view that order.'
    end
  end

  def invoice
    if can_access_order?
      i = Invoice.new(order: @order, invoice_details: @w.invoice_details)
      i.generate
      send_file(i.filename)
    else
      redirect_to new_session_path
    end
  end

  protected

  def can_access_order?
    admin_or_manager? || @current_user.id == @order.user_id
  end

  # get valid order from current session or send user back to their basket
  def require_order
    @order = Order.from_session session
    if @order.nil?
      redirect_to({controller: 'basket', action: 'index'},
        notice: "We couldn't find an order for you.")
    end
  end

  # get specific order
  def find_order
    @order = Order.find_by(id: params[:id], website_id: @w.id)
    if @order.nil?
      redirect_to orders_path, notice: 'Cannot find order.'
    end
  end

  def prepare_cardsave
    @cardsave_transaction_date_time = cardsave_transaction_date_time
    @cardsave_hash = cardsave_hash_pre
  end

  def cardsave_transaction_date_time
    offset = Time.now.strftime '%z'
    Time.now.strftime '%Y-%m-%d %H:%M:%S ' + offset[0..2] + ':' + offset[3..4]
  end

  def cardsave_hash_pre
    plain="PreSharedKey=" + @w.cardsave_pre_shared_key
    plain=plain + '&MerchantID=' + @w.cardsave_merchant_id
    plain=plain + '&Password=' + @w.cardsave_password
    plain=plain + '&Amount=' + (@order.total * 100).to_int.to_s
    plain=plain + '&CurrencyCode=826'
    plain=plain + '&OrderID=' + @order.order_number
    plain=plain + '&TransactionType=SALE'
    plain=plain + '&TransactionDateTime=' + @cardsave_transaction_date_time
    plain=plain + '&CallbackURL=' + cardsave_callback_payments_url
    plain=plain + '&OrderDescription=Web purchase';
    plain=plain + '&CustomerName=' + @order.full_name
    plain=plain + '&Address1=' + @order.address_line_1
    plain=plain + '&Address2=' + @order.address_line_2
    plain=plain + '&Address3='
    plain=plain + '&Address4='
    plain=plain + '&City=' + @order.town_city
    plain=plain + '&State=' + @order.county
    plain=plain + '&PostCode=' + @order.postcode
    plain=plain + '&CountryCode=826'
    plain=plain + "&CV2Mandatory=true"
    plain=plain + "&Address1Mandatory=true"
    plain=plain + "&CityMandatory=true"
    plain=plain + "&PostCodeMandatory=true"
    plain=plain + "&StateMandatory=true"
    plain=plain + "&CountryMandatory=true"
    plain=plain + "&ResultDeliveryMethod=" + 'POST';
    plain=plain + "&ServerResultURL="
    plain=plain + "&PaymentFormDisplaysResult=" + 'false';

    require 'digest/sha1'
    Digest::SHA1.hexdigest(plain)
  end
end
