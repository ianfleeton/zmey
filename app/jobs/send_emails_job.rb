class SendEmailsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    DispatchNotifier.new.send_emails
    InvoiceNotifier.new.send_emails
  end
end
