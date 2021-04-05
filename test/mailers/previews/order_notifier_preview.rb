class OrderNotifierPreview < ActionMailer::Preview
  def notification
    website = Website.new(name: 'I Saw You Coming', vat_number: '123 456 789')
    user = User.new
    user.name = 'Ian'
    order = Order.new
    order.delivery_full_name = 'Ian Fleeton'
    order.email_address = 'ianf@yesl.co.uk'

    order.delivery_address_line_1 = '13 My Street'
    order.delivery_address_line_2 = 'Locality'
    order.delivery_town_city = 'Town'
    order.delivery_county = 'County'
    order.delivery_postcode = 'L0N D0N'

    order.order_number = '20131206-AX0W'
    order.shipping_method = 'Standard shipping'
    order.status = Order::PAYMENT_RECEIVED
    order.website = website
    order.order_lines << OrderLine.new(product_sku: 'WDG123', product_name: 'A shabby chic coffee table', feature_descriptions: 'Coffee stains: Included', product_price: 975, quantity: 1, vat_amount: 195)
    order.total = 1170

    OrderNotifier.notification(website, order)
  end
end
