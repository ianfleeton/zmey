class OrderNotifier < ActionMailer::Base
  include EmailSetup

  helper :orders
  helper :products # price formatting
  helper :addresses # address formatting

  def notification website, order
    send_to_customer_and_admin(website, order, 'order notification')
  end

  def dispatch(website, order)
    send_to_customer_and_admin(website, order, 'order dispatched')
  end

  def invoice(website, order)
    invoice = PDF::Invoice.new(order)
    invoice.generate
    attachments[invoice_filename(order)] = File.read(invoice.filename)
    send_to_customer_and_admin(website, order, 'your invoice')
  end

  def send_to_customer_and_admin(website, order, what)
    recipients = [order.email_address, website.email]
    @website = website
    @order = order
    mail(to: recipients, subject: "#{website.name}: #{what} #{order.order_number}",
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

  private

    def invoice_filename(order)
      "Order #{order.order_number} - Invoice.pdf"
    end
end
