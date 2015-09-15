class OrderNotifier < ActionMailer::Base
  include EmailSetup

  helper :orders
  helper :products # price formatting
  helper :addresses # address formatting

  def notification website, order
    send_to_customer_and_admin(website: website, order: order, what: 'order notification')
  end

  def dispatch(website, shipment)
    send_to_customer_and_admin(website: website, order: shipment.order, shipment: shipment, what: 'order dispatched')
  end

  def invoice(website, order)
    invoice = PDF::Invoice.new(order)
    invoice.generate
    attachments[invoice_filename(order)] = File.read(invoice.filename)
    send_to_customer_and_admin(website: website, order: order, what: 'your invoice')
  end

  def send_to_customer_and_admin(website:, order:, shipment: nil, what:)
    recipients = [order.email_address, website.email_address]
    @website = website
    @order = order
    @shipment = shipment
    mail(to: recipients, subject: "#{website.name}: #{what} #{order.order_number}",
      from: website.email_address)
  end

  def admin_waiting_for_payment(website, order)
    recipients = [website.email_address]
    @website = website
    @order = order
    mail(to: recipients, subject: website.name + ': waiting for payment ' + order.order_number,
      from: website.email_address)
    render 'notification'
  end

  private

    def invoice_filename(order)
      "Order #{order.order_number} - Invoice.pdf"
    end
end
