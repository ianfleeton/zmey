class DispatchNotifier
  # Sends outstanding dispatch notification emails to customers.
  def send_emails
    pending_orders.each do |order|
      send_email(order)
      record_sent(order)
    end
  end

  # Sends a dispatch notification email to the customer of the <tt>order</tt>.
  def send_email(order)
    OrderNotifier.dispatch(Website.first, order).deliver_now
  end

  # Records within <tt>order</tt> that the dispatch notification email has
  # been sent.
  def record_sent(order)
    # Skip validation because we don't want to spam the customer if there are
    # any order validation problems.
    order.update_attribute(:shipment_email_sent_at, Time.zone.now)
  end

  # Returns a list of orders that are requiring a dispatch notification to be
  # sent to the customer.
  def pending_orders
    Order.where('shipped_at IS NOT NULL AND shipment_email_sent_at IS NULL')
  end
end
