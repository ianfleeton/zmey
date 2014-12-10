class OrderNotifier < ActionMailer::Base
  include EmailSetup

  helper :orders
  helper :products # price formatting
  helper :addresses # address formatting

  def notification website, order
    recipients = [order.email_address, website.email]
    @website = website
    @order = order
    mail(to: recipients, subject: website.name + ': order notification ' + order.order_number,
      from: website.email)
  end

  def admin_waiting_for_payment(website, order)
    recipients = [website.email]
    @website = website
    @order = order
    mail(to: recipients, subject: website.name + ': waiting for payment ' + order.order_number,
      from: website.email)
    render 'notification'
  end
end
