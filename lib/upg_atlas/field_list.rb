module UpgAtlas
  class FieldList
    def initialize(order:, checkcode:, shreference:, callbackurl:, filename:, secuphrase:)
      @order = order
      @checkcode = checkcode
      @shreference = shreference
      @callbackurl = callbackurl
      @filename = filename
      @secuphrase = secuphrase
    end

    # Returns an array of hidden field name/value pairs for use in the UPG
    # Atlas payment form.
    def fields
      base_fields << ['secuString', secustring]
    end

    # Returns a string describing the data we want returned to us in the UPG
    # Atlas callback.
    def callbackdata
      [
        'transactionamount', '#transactionamount',
        'transactioncurrency', '#transactioncurrency',
        'ordernumber', @order.order_number,
        'cardholderaddr1', '#cardholderaddr1',
        'cardholderaddr2', '#cardholderaddr2',
        'cardholdercity', '#cardholdercity',
        'cardholderstate', '#cardholderstate',
        'cardholderpostcode', '#cardholderpostcode',
        'cardholdercountry', '#cardholdercountry',
        'cardholdersname', '#cardholdersname',
        'cardholdersemail', '#cardholdersemail',
        'cardholderstelephonenumber', '#cardholderstelephonenumber',
      ].join('|')
    end

    # Returns a string describing the order contents. Used for the secuitems
    # hidden field.
    def secuitems
      @order.order_lines.map { |ol| "[#{secuitem(ol)}]" }.join
    end

    # Returns a secure string obtained from UPG Atlas to prevent tampering.
    def secustring
      url = 'https://www.secure-server-hosting.com/secutran/create_secustring.php'
      c = Curl::Easy.perform(url) do |curl|
        curl.headers['Referer'] = 'https://zmey.co.uk/'
        curl.encoding = 'UTF-8'
        curl.ssl_verify_peer = false
        curl.verbose = true
        puts secustring_request_body
        curl.post_body = secustring_request_body
      end
      secustring_from_response(c.body_str)
    end

    private

      def secuitem(order_line)
        [
          order_line.product_sku,
          order_line.product_sku,
          order_line.product_name,
          '%.2f' % order_line.product_price,
          order_line.quantity.round,
          '%.2f' % order_line.line_total_net,
        ].join('|')
      end

      def base_fields
        @base_fields ||= [
          ['checkcode', @checkcode],
          ['secuitems', secuitems],
          ['secuphrase', @secuphrase],
          ['filename', "#{@shreference}/#{@filename}"],
          ['shippingcharge', 0],
          ['shreference', @shreference],
          ['callbackurl', @callbackurl],
          ['callbackdata', callbackdata],
          ['transactionamount', @order.total],
          ['transactioncurrency', 'GBP'],
          ['transactiontax', 0],
          ['cardholdersname', @order.billing_full_name],
          ['cardholdersemail', @order.email_address],
          ['cardholderaddr1', @order.billing_address_line_1],
          ['cardholderaddr2', @order.billing_address_line_2],
          ['cardholdercity', @order.billing_town_city],
          ['cardholderstate', @order.billing_county],
          ['cardholderpostcode', @order.billing_postcode],
          ['cardholdercountry', @order.billing_country.name],
          ['cardholdertelephonenumber', @order.billing_phone_number],
        ]
      end

      def secustring_request_body
        base_fields
          .map {|f| "#{f[0]}=#{CGI::escape(f[1].to_s)}"}
          .join('&')
      end

      def secustring_from_response(response)
        # Expected response should be:
        # <input type="hidden" id="secuString" name="secuString" value="$secuString" />
        parts = response.split('"')
        if parts[0] == '<input type='
          parts[7]
        else
          raise "Unexpected response from UPG Atlas secustring: #{response}"
        end
      end
  end
end
