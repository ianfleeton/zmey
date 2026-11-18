# A base class for sending outstanding notification emails to customers in the
# background.
#
# Each object is claimed by setting its sent at attribute with a conditional
# update before its email is sent, so overlapping runs never email the same
# customer twice. If sending fails the claim is released so a later run can
# try again.
class BackgroundNotifier
  # Sends outstanding emails to customers.
  def send_emails
    pending_objects.each do |object|
      next unless claim(object)

      begin
        send_email(object)
      rescue
        release(object)
        raise
      end
    end
  end

  # Override to send the email.
  def send_email(object)
    # SomeNotifier.notification(...).deliver_now
  end

  # Override to return the attribute that records when the email was sent.
  def sent_at_attribute
    # :my_email_sent_at
  end

  # Override to return the objects whose emails haven't been sent.
  def pending_objects
    # Object.where('some_status IS NOT NULL AND my_email_sent_at IS NULL')
    []
  end

  # Records that the email for +object+ is being sent. Returns false if
  # another run has already claimed it.
  #
  # Validation and callbacks are skipped because we don't want to spam the
  # customer if there are any validation problems.
  def claim(object)
    now = Time.current
    claimed = object.class
      .where(:id => object.id, sent_at_attribute => nil)
      .update_all(sent_at_attribute => now) == 1
    object[sent_at_attribute] = now if claimed
    claimed
  end

  private

  def release(object)
    object.class.where(id: object.id).update_all(sent_at_attribute => nil)
    object[sent_at_attribute] = nil
  end
end
