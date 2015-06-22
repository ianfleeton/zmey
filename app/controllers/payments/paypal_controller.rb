class Payments::PaypalController < PaymentsController
  def auto_return
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
    redirect_to payments_paypal_confirmation_path, notice:
      "#{@message} You may log into your account at www.paypal.com/uk to view details of this transaction."
  end

  def confirmation
  end

  private

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
        payment_status: '',
        charset: 'utf-8',
      }

      data = pdt_notification_sync_response_body(transaction_token, identity_token)
      Rails.logger.info data

      response[:raw_auth_message] = data
      response[:status] = data.split[0].strip

      data.split[1..-1].each do |line|
        key, value = line.strip.split('=')
        key = key.to_sym
        response[key] = CGI::unescape(value || '') if response.has_key? key
      end

      charset = response[:charset]
      Hash[response.map { |k,v| [k,v.force_encoding(charset).encode('utf-8')] }]
    end

    def pdt_notification_sync_response_body(transaction_token, identity_token)
      require 'net/https'
      uri = URI('https://www.paypal.com/cgi-bin/webscr')
      data = "cmd=_notify-synch&tx=#{transaction_token}&at=#{identity_token}"
      con = Net::HTTP.new(uri.host, uri.port)
      con.use_ssl = true
      r = con.post(uri.path, data)
      r.body
    end
end
