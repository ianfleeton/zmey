class PaymentsController < ApplicationController
  include ResetBasket

  skip_before_action :verify_authenticity_token, only: [:cardsave_callback, :paypal_auto_return, :rbs_worldpay_callback]

  before_action :admin_required, only: [:index, :show]

  layout 'admin', only: [:index, :show]

  FAILURE_MESSAGE = 'Some information was incorrect and your payment may not have gone through properly. Please contact us.'

  def index
    @payments = Payment.order('created_at DESC')
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def paypal_auto_return
    response = pdt_notification_sync(params[:tx], website.paypal_identity_token)
    @payment = Payment.new
    @payment.service_provider = 'PayPal'
    @payment.installation_id = website.paypal_email_address
    @payment.cart_id = response[:item_name]
    @payment.description = 'Web purchase'
    @payment.amount = response[:mc_gross]
    @payment.currency = response[:mc_currency]
    @payment.test_mode = false
    @payment.name = response[:address_name]
    @payment.address = "#{response[:address_street]}\n#{response[:address_city]}\n#{response[:address_state]}"
    @payment.postcode = response[:address_zip]
    @payment.country = response[:address_country_code]
    @payment.telephone = response[:contact_phone]
    @payment.fax = ''
    @payment.email = response[:payer_email]
    @payment.transaction_id = response[:txn_id]
    @payment.transaction_status = ('SUCCESS' == response[:status])
    @payment.transaction_time = response[:payment_date]
    @payment.raw_auth_message = response[:raw_auth_message]
    @payment.accepted = ('SUCCESS' == response[:status]) &&
      (['Completed', 'Processed'].include? response[:payment_status])
    @payment.save

    if @payment.accepted?
      clean_up
      @message = 'Thank you for your payment. Your transaction has been completed and a receipt for your purchase has been emailed to you.'
    else
      @message = 'We could not confirm your payment was successful.'
    end

    @payment.save
    redirect_to paypal_confirmation_payments_path, notice:
      "#{@message} You may log into your account at www.paypal.com/uk to view details of this transaction."
  end

  def cardsave_callback
    @payment = Payment.new
    @payment.service_provider = 'Cardsave'
    @payment.installation_id = params[:MerchantID]
    @payment.cart_id = params[:OrderID]
    @payment.description = params[:OrderDescription]
    @payment.amount = '%.2f' % (params[:Amount].to_f/100)
    @payment.currency = params[:CurrencyCode]
    @payment.test_mode = false
    @payment.name = params[:CustomerName]
    @payment.address = cardsave_address
    @payment.postcode = params[:PostCode]
    @payment.country = params[:CountryCode]
    @payment.telephone = params[:PhoneNumber]
    @payment.email = params[:EmailAddress]
    @payment.transaction_id = params[:OrderID]
    @payment.transaction_status = (params[:StatusCode] and params[:StatusCode]=='0')
    @payment.transaction_time = params[:TransactionDateTime]
    @payment.accepted = false # for now
    @payment.save # this first save is for safety

    if cardsave_hash_matches?
      if params[:StatusCode]=='0'
        @message = I18n.t('controllers.payments.cardsave_callback.flash.accepted')
        @payment.accepted = true
        clean_up
      elsif params[:StatusCode]=='5'
        @message = I18n.t('controllers.payments.cardsave_callback.flash.declined')
      elsif params[:StatusCode]=='30'
        @message = I18n.t('controllers.payments.cardsave_callback.flash.processing_error')
      else
        @message = I18n.t('controllers.payments.cardsave_callback.flash.unknown')
      end
    else
      @message = I18n.t('controllers.payments.cardsave_callback.flash.hash_mismatch')
    end
    @payment.save
    render layout: false
  end

  def rbs_worldpay_callback
    @payment = Payment.new
    @payment.service_provider = 'WorldPay'
    @payment.installation_id = params[:instId]
    @payment.cart_id = params[:cartId]
    @payment.description = params[:desc]
    @payment.amount = params[:amount]
    @payment.currency = params[:currency]
    @payment.test_mode = (params[:testMode] != '0')
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
    @payment.raw_auth_message = params[:rawAuthMessage]
    @payment.accepted = false # for now
    @payment.save # this first save is for safety

    if params[:transStatus].nil? or params[:transStatus] != 'Y'
      @message = 'No payment was made'
    elsif !website.skip_payment? and (params[:callbackPW].nil? or params[:callbackPW] != website.worldpay_payment_response_password)
      @message = FAILURE_MESSAGE
    elsif params[:cartId].nil?
      @message = FAILURE_MESSAGE
    elsif params[:testMode] and !website.worldpay_test_mode? and params[:testMode] != '0'
      @message = FAILURE_MESSAGE
    else
      @message = 'Payment received'
      @payment.accepted = true
      clean_up
    end
    @payment.save
    render layout: false
  end

  def sage_pay_failure
  end

  def sage_pay_success
    raise unless params[:crypt]

    sage_pay = SagePay.new(
      encrypted: params[:crypt],
      pre_shared_key: website.sage_pay_pre_shared_key
    )
    results = sage_pay.decrypt

    @payment = Payment.find_by(transaction_id: results['VPSTxId'])
    if @payment
      redirect_to receipt_orders_path
    else
      @payment = Payment.create!(
        service_provider: 'Sage Pay',
        installation_id: website.sage_pay_vendor,
        cart_id: results['VendorTxCode'],
        description: 'Web purchase',
        amount: results['Amount'],
        currency: results['GBP'],
        test_mode: website.sage_pay_test_mode,
        transaction_id: results['VPSTxId'],
        transaction_status: results['Status'] == 'OK',
        transaction_time: Time.zone.now,
        raw_auth_message: sage_pay.plaintext,
        accepted: false
      )
      if @payment.transaction_status
        @message = 'Payment received'
        @payment.accepted = true
        clean_up
        @payment.save
        redirect_to receipt_orders_path
      else
        redirect_to checkout_path, notice: 'Payment not received'
      end
    end
  end

  private

  def update_order order
    order.status = Order::PAYMENT_RECEIVED
    order.save
    @payment.order_id = order.id
    OrderNotifier.notification(@w, order).deliver
  end

  def clean_up
    if order = Order.find_by(order_number: @payment.cart_id)
      reset_basket(order)
      update_order order
    end
  end

  def pdt_notification_sync(transaction_token, identity_token)
    response = {
      status: 'FAIL',
      item_name: '',
      mc_gross: '0.00',
      mc_currency: '',
      address_name: '',
      address_street: '',
      address_city: '',
      address_state: '',
      address_zip: '',
      address_country_code: '',
      contact_phone: '',
      payer_email: '',
      txn_id: '',
      payment_date: '',
      raw_auth_message: '',
      payment_status: ''
    }

    require 'net/https'
    uri = URI('https://www.paypal.com/cgi-bin/webscr')
    data = "cmd=_notify-synch&tx=#{transaction_token}&at=#{identity_token}"
    con = Net::HTTP.new(uri.host, uri.port)
    con.use_ssl = true
    r = con.post(uri.path, data)
    data = r.body
    Rails.logger.info data

    response[:raw_auth_message] = data
    response[:status] = data.split[0].strip

    data.split[1..-1].each do |line|
      key, value = line.strip.split('=')
      key = key.to_sym
      response[key] = CGI::unescape(value || '') if response.has_key? key
    end

    response
  end

  def cardsave_hash_post
    plain="PreSharedKey=" + website.cardsave_pre_shared_key
    plain=plain + '&MerchantID=' + website.cardsave_merchant_id
    plain=plain + '&Password=' + website.cardsave_password
    plain=plain + '&StatusCode=' + params[:StatusCode]
    plain=plain + '&Message=' + params[:Message]
    plain=plain + '&PreviousStatusCode=' + params[:PreviousStatusCode]
    plain=plain + '&PreviousMessage=' + params[:PreviousMessage]
    plain=plain + '&CrossReference=' + params[:CrossReference]
    plain=plain + '&Amount=' + params[:Amount]
    plain=plain + '&CurrencyCode=' + params[:CurrencyCode]
    plain=plain + '&OrderID=' + params[:OrderID]
    plain=plain + '&TransactionType=' + params[:TransactionType]
    plain=plain + '&TransactionDateTime=' + params[:TransactionDateTime]
    plain=plain + '&OrderDescription=' + params[:OrderDescription]
    plain=plain + '&CustomerName=' + params[:CustomerName]
    plain=plain + '&Address1=' + params[:Address1]
    plain=plain + '&Address2=' + params[:Address2]
    plain=plain + '&Address3=' + params[:Address3]
    plain=plain + '&Address4=' + params[:Address4]
    plain=plain + '&City=' + params[:City]
    plain=plain + '&State=' + params[:State]
    plain=plain + '&PostCode=' + params[:PostCode]
    plain=plain + '&CountryCode=' + params[:CountryCode]

    require 'digest/sha1'
    Digest::SHA1.hexdigest(plain)
  end

  def cardsave_hash_matches?
    params[:HashDigest] == cardsave_hash_post
  end

  def cardsave_address
    [:Address1, :Address2, :Address3, :Address4, :City, :State].map{|k|params[k]}.join("\n").gsub(/\n+/, "\n")
  end
end
