class AddIndexesToShipments < ActiveRecord::Migration
  def change
    add_index :shipments, :email_sent_at
    add_index :shipments, :order_id
    add_index :shipments, :shipped_at
  end
end
