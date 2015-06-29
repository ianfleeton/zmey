module CheckoutHelper
  # Returns a string describing the data we want returned to us in the UPG
  # Atlas callback.
  def upg_atlas_callbackdata(order)
    [
      'transactionamount', '#transactionamount',
      'transactioncurrency', '#transactioncurrency',
      'ordernumber', order.order_number,
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

  # Returns a string describing the order contents.
  def upg_atlas_secuitems(order_lines)
    order_lines.map { |ol| "[#{upg_atlas_secuitem(ol)}]" }.join
  end

  private

    def upg_atlas_secuitem(order_line)
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
