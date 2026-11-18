class InvoiceNotifier < BackgroundNotifier
  # Sends an invoice notification email to the customer of the <tt>order</tt>.
  def send_email(order)
    OrderNotifier.invoice(Website.first, order).deliver_now
  end

  def sent_at_attribute
    :invoice_sent_at
  end

  # Returns a list of orders that are requiring an invoice notification to be
  # sent to the customer.
  def pending_objects
    Order.where("shipped_at IS NOT NULL AND invoice_sent_at IS NULL")
  end
end
