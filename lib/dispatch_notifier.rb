class DispatchNotifier < BackgroundNotifier
  # Sends a dispatch notification email to the customer of the <tt>shipment</tt>.
  def send_email(shipment)
    OrderNotifier.dispatch(Website.first, shipment).deliver_now
  end

  # Records within <tt>shipment</tt> that the dispatch notification email has
  # been sent.
  def record_sent(shipment)
    # Skip validation because we don't want to spam the customer if there are
    # any shipment validation problems.
    shipment.update_attribute(:email_sent_at, Time.zone.now)
  end

  # Returns a list of shipments that are requiring a dispatch notification to be
  # sent to the customer.
  def pending_objects
    Shipment.where('shipped_at IS NOT NULL AND email_sent_at IS NULL')
  end
end
