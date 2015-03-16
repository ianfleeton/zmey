class AddSendPendingPaymentEmailsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :send_pending_payment_emails, :boolean, default: true, null: false
  end
end
