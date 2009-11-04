class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:rbs_worldpay_callback]

  before_filter :admin_required, :only => [:index, :show]

  FAILURE_MESSAGE = 'Some information was incorrect and your payment may not have gone through properly. Please contact us.'

  def index
    @payments = Payment.all(:order => 'created_at desc')
  end
  
  def show
    @payment = Payment.find(params[:id])
  end

  def rbs_worldpay_callback
    @payment = Payment.new
    @payment.service_provider = 'RBS WorldPay'
    @payment.installation_id = params[:instId]
    @payment.cart_id = params[:cartId]
    @payment.description = params[:desc]
    @payment.amount = params[:amount]
    @payment.currency = params[:currency]
    @payment.test_mode = params[:testMode]
    @payment.name = params[:name]
    @payment.address = params[:address]
    @payment.postcode = params[:postcode]
    @payment.country = params[:country]
    @payment.telephone = params[:tel]
    @payment.fax = params[:fax]
    @payment.email = params[:email]
    @payment.transaction_id = params[:transId]
    @payment.transaction_status = (params[:transStatus] and params[:transStatus]=='Y')
    @payment.transaction_time = params[:transTime]
    @payment.raw_auth_message = params[:RawAuthMessage]
    @payment.accepted = false # for now
    @payment.save # this first save is for safety

    if params[:transStatus].nil? or params[:transStatus] != 'Y'
      @message = 'No payment was made'
    elsif !@w.skip_payment? and (params[:callbackPW].nil? or params[:callbackPW] != @w.rbswp_payment_response_password)
      @message = FAILURE_MESSAGE
    elsif params[:cartId].nil?
      @message = FAILURE_MESSAGE
    elsif params[:testMode] and !@w.rbswp_test_mode? and params[:testMode] != '0'
      @message = FAILURE_MESSAGE      
    else
      @message = 'Payment received'
      @payment.accepted = true
      clean_up
    end
    @payment.save
    render :layout => false
  end
  
  private
  
  def update_order order
    order.status = Order::PAYMENT_RECEIVED
    order.save
    @payment.order_id = order.id
    OrderNotifier.deliver_notification @w, order
  end

  def clean_up
    if order = Order.find_by_order_number(@payment.cart_id)
      order.empty_basket
      update_order order
    end
  end
end
