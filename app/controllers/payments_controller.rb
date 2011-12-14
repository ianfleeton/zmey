class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:cardsave_callback, :paypal_auto_return, :rbs_worldpay_callback]

  before_filter :admin_required, :only => [:index, :show]

  FAILURE_MESSAGE = 'Some information was incorrect and your payment may not have gone through properly. Please contact us.'

  def index
    @payments = Payment.all(:order => 'created_at desc')
  end
  
  def show
    @payment = Payment.find(params[:id])
  end

  def paypal_auto_return
    response = pdt_notification_sync(params[:tx], @w.paypal_identity_token)
    @payment = Payment.new
    @payment.service_provider = 'PayPal'
    @payment.installation_id = @w.paypal_email_address
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

    redirect_to paypal_confirmation_payments_path, :notice =>
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
        @message = "Payment received"
        @payment.accepted = true
        clean_up
      elsif params[:StatusCode]=='5'
        @message = "Payment declined"
      elsif params[:StatusCode]=='30'
        @message = "There was an error processing your card transaction"
      else
        @message = "We cannot confirm that your payment was successful"
      end
    else
      @message = "There was a failure validating your payment"
    end
    @payment.save
    render :layout => false
  end

  def rbs_worldpay_callback
    @payment = Payment.new
    @payment.service_provider = 'RBS WorldPay'
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
    OrderNotifier.notification(@w, order).deliver
  end

  def clean_up
    if order = Order.find_by_order_number(@payment.cart_id)
      order.empty_basket(session)
      update_order order
    end
  end

  def pdt_notification_sync(transaction_token, identity_token)
    response = {
      :status => 'FAIL',
      :item_name => '',
      :mc_gross => '0.00',
      :mc_currency => '',
      :address_name => '',
      :address_street => '',
      :address_city => '',
      :address_state => '',
      :address_zip => '',
      :address_country_code => '',
      :contact_phone => '',
      :payer_email => '',
      :txn_id => '',
      :payment_date => '',
      :raw_auth_message => '',
      :payment_status => ''
    }

    require 'net/https'
    uri = URI('https://www.paypal.com/cgi-bin/webscr')
    data = "cmd=_notify-synch&tx=#{transaction_token}&at=#{identity_token}"
    con = Net::HTTP.new(uri.host, uri.port)
    con.use_ssl = true
    r, data = con.post(uri.path, data)
    Rails.logger.info data

    response[:raw_auth_message] = data
    response[:status] = data.to_a[0].strip

    data.to_a[1..-1].each do |line|
      key, value = line.strip.split('=')
      key = key.to_sym
      response[key] = CGI::unescape(value) if response.has_key? key
    end

    response
  end

  def cardsave_hash_post
    plain="PreSharedKey=" + @w.cardsave_pre_shared_key
    plain=plain + '&MerchantID=' + @w.cardsave_merchant_id
    plain=plain + '&Password=' + @w.cardsave_password
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
