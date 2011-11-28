class OrderNotifier < ActionMailer::Base
  helper :products # price formatting
  helper :addresses # address formatting

  def notification website, order
    recipients [order.email_address, website.email]
    from website.email
    @website = website
    @order = order
    mail(:to => recipients, :subject => website.name + ': order notification ' + order.order_number)
  end
end
