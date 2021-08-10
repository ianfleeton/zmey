class OrderNotifier < ActionMailer::Base
  include EmailSetup

  helper :application # nl2br
  helper :orders
  helper :products # price formatting
  helper :addresses # address formatting

  # Sends the initial order confirmation with ordering and right to cancel
  # information attached as a PDF.
  def confirmation(website, order)
    attach_order_confirmation_info
    send_to_customer_and_merchant(
      website: website, order: order, what: "order confirmation"
    )
    order.update_columns(confirmation_sent_at: Time.current) if order.persisted?
  end

  def dispatch(website, shipment)
    send_to_customer_and_merchant(website: website, order: shipment.order, shipment: shipment, what: "order dispatched")
  end

  def invoice(website, order)
    invoice = PDF::Invoice.new(order)
    invoice.generate
    attachments[invoice_filename(order)] = File.read(invoice.filename)
    send_to_customer_and_merchant(website: website, order: order, what: "your invoice")
  end

  def send_to_customer_and_merchant(website:, order:, what:, shipment: nil)
    recipients = [order.email_address, website.order_notifier_email]

    @website = website

    @order = order
    @shipment = shipment
    mail(
      to: recipients,
      subject: "#{website.name}: #{what} #{order.order_number}",
      from: website.email_address
    )
  end

  def admin_waiting_for_payment(website, order)
    recipients = [website.email_address]
    @website = website
    @order = order
    mail(to: recipients, subject: website.name + ": waiting for payment " + order.order_number,
      from: website.email_address)
    render "notification"
  end

  private

  def attach_order_confirmation_info
    pdf = PDF::OrderConfirmationInfo.new
    pdf.generate
    attachments["InfoAndRightToCancel.pdf"] = File.read(pdf.filename)
  end

  def invoice_filename(order)
    "Order #{order.order_number} - Invoice.pdf"
  end
end
