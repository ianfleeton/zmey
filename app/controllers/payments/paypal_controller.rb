# frozen_string_literal: true

class Payments::PaypalController < PaymentsController
  skip_before_action :verify_authenticity_token, :protect_staging_website, only: [:auto_return, :ipn_listener]
  DISPUTE = "dispute"

  def new
    @order = Order.find_by(order_number: params[:order_number])

    fingerprint = Security::OrderFingerprint.new(@order)
    if fingerprint != params[:fingerprint]
      return cannot_pay("The payment link is no longer valid")
    end

    return cannot_pay("This order is fully paid!") if @order.payment_received?

    cookies.signed[:order_id] = @order.id
  end

  def auto_return
    @payment = Payment.new
    begin
      response = pdt_notification_sync(params[:tx], website.paypal_identity_token)
      @payment.service_provider = "PayPal"
      @payment.installation_id = website.paypal_email_address
      copy_paypal_details(payment: @payment, details: response)
      @payment.test_mode = false
      @payment.address = "#{response[:address_street]}\n#{response[:address_city]}\n#{response[:address_state]}"
      @payment.postcode = response[:address_zip]
      @payment.country = response[:address_country_code]
      @payment.telephone = response[:contact_phone]
      @payment.fax = ""
      @payment.transaction_status = (response[:status] == "SUCCESS")
      @payment.raw_auth_message = response[:raw_auth_message]
      @payment.accepted = (response[:status] == "SUCCESS") &&
        (%w[Completed Processed].include? response[:payment_status])
      @payment.save
    rescue SocketError
      return finish_auto_return(
        basket_path,
        "Sorry, we could not communicate with PayPal to find out if your payment was successful."
      )
    end

    if @payment.accepted?
      finalize_order
      finish_auto_return(receipt_orders_path, "Thank you for your payment. Your transaction has been completed and a receipt for your purchase has been emailed to you.")
    else
      finish_auto_return(basket_path, "We could not confirm your payment was successful.")
    end
  end

  def finish_auto_return(destination, message)
    redirect_to(destination, notice: "#{message} You may log into your account at www.paypal.com/uk to view details of this transaction.")
  end

  # Listens for PayPal IPN messages and records payments for valid messages.
  def ipn_listener
    utf8_params = convert_to_utf8(params.to_unsafe_h)
    if dispute?(utf8_params)
      order = Order.find_by order_number: utf8_params[:custom]
      if order
        order.order_comments << OrderComment.create(comment: "Order dispute received from PayPal for reason #{utf8_params[:reason_code]}")
      else
        Rails.logger.error "Recieved PayPal dispute and could not find an order to comment on. Case ID: #{params[:case_id]}"
      end
    elsif ipn_valid?(params.to_unsafe_h)
      @payment = Payment.new(service_provider: "PayPal (IPN)")
      @payment.installation_id = utf8_params[:business]
      copy_paypal_details(payment: @payment, details: utf8_params)
      @payment.raw_auth_message = utf8_params
      @payment.accepted = utf8_params[:payment_status] == "Completed"
      @payment.save!

      finalize_order if @payment.accepted?
    end
    head :ok
  rescue SocketError => error
    Rails.logger.error(error)
    # Even though it's probably not our fault, signal to PayPal that we're
    # having a problem. This should prompt PayPal to retry the IPN.
    head 500
  end

  private

  def dispute?(params)
    params[:case_type] == DISPUTE
  end

  def cannot_pay(alert)
    flash[:alert] = alert
    redirect_to root_path
  end

  def pdt_notification_sync(transaction_token, identity_token)
    response = {
      status: "FAIL",
      item_name: "",
      mc_gross: "0.00",
      mc_currency: "",
      address_name: "",
      address_street: "",
      address_city: "",
      address_state: "",
      address_zip: "",
      address_country_code: "",
      contact_phone: "",
      payer_email: "",
      txn_id: "",
      payment_date: "",
      raw_auth_message: "",
      payment_status: "",
      charset: "utf-8"
    }

    data = pdt_notification_sync_response_body(transaction_token, identity_token)
    Rails.logger.info data

    response[:raw_auth_message] = data
    response[:status] = data.split[0].strip

    data.split[1..].each do |line|
      key, value = line.strip.split("=")
      key = key.to_sym
      response[key] = CGI.unescape(value || "") if response.key? key
    end

    convert_to_utf8(response)
  end

  # Converts a hash from charset specified in hash[:charset] to UTF-8.
  # Keys are symbolized.
  def convert_to_utf8(hash)
    charset = hash[:charset]
    hash.map { |k, v| [k, v.dup.force_encoding(charset).encode("utf-8")] }.to_h.symbolize_keys
  end

  def pdt_notification_sync_response_body(transaction_token, identity_token)
    require "net/https"
    uri = URI(paypal_endpoint)
    data = "cmd=_notify-synch&tx=#{transaction_token}&at=#{identity_token}"
    con = Net::HTTP.new(uri.host, uri.port)
    con.use_ssl = true
    r = con.post(uri.path, data)
    r.body
  end

  # Returns <tt>true</tt> if the provided IPN message is valid.
  def ipn_valid?(message)
    require "net/https"
    uri = URI(paypal_endpoint)
    data = "cmd=_notify-validate&" + message.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join("&")
    con = Net::HTTP.new(uri.host, uri.port)
    con.use_ssl = true
    r = con.post(uri.path, data)
    r.body.include?("VERIFIED")
  end

  # Returns a production or sandbox PayPal https endpoint.
  def paypal_endpoint
    if website.paypal_test_mode?
      "https://www.sandbox.paypal.com/cgi-bin/webscr"
    else
      "https://www.paypal.com/cgi-bin/webscr"
    end
  end

  def copy_paypal_details(payment:, details:)
    payment.amount = details[:mc_gross]
    set_cart_id(payment: payment, details: details)
    payment.currency = details[:mc_currency]
    payment.description = "Web purchase"
    payment.email = details[:payer_email]
    payment.name = details[:address_name]
    payment.transaction_id = details[:txn_id]
    payment.transaction_time = details[:payment_date]
  end

  def set_cart_id(payment:, details:)
    payment.cart_id = if details[:item_name] == "Shopping Cart"
      details[:custom]
    else
      details[:item_name] || details[:item_name1]
    end
  end
end
