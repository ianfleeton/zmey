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
      [
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
  end
end
