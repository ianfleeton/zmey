class AddShipmentEmailSentAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipment_email_sent_at, :datetime
  end
end
