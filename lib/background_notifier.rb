# A base class for sending outstanding notification emails to customers in the
# background.
class BackgroundNotifier
  # Sends oustanding emails to customers.
  def send_emails
    pending_objects.each do |object|
      send_email(object)
      record_sent(object)
    end
  end

  # Override to send the email.
  def send_email(object)
    # SomeNotifier.notification(...).deliver_now
  end

  # Override to record that the email has been sent.
  def record_sent(object)
    # It is a good idea to skip validation because we don't want to spam the
    # customer if there are any validation problems.
    # object.update_attribute(:my_email_sent_at, Time.zone.now)
  end

  # Override to return a list of objects that are requiring a notification to
  # be sent to the customer.
  def pending_objects
    # Object.where('some_status IS NOT NULL AND my_email_sent_at IS NULL')
    []
  end
end
