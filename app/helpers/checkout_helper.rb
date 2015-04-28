module CheckoutHelper
  # Returns a string describing the data we want returned to us in the UPG
  # Atlas callback.
  def upg_atlas_callbackdata(order)
    [
      'amount', '#amount',
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
end
