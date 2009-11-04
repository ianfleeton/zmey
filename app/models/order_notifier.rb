class OrderNotifier < ActionMailer::Base
  helper :products # price formatting
  helper :addresses # address formatting

  def notification website, order
    subject website.name + ': order notification ' + order.order_number
    recipients [order.email_address, website.email]
    from website.email
    sent_on Time.now
    body :website => website, :order => order
  end
end
