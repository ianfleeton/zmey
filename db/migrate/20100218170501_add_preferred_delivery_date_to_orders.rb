class AddPreferredDeliveryDateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :preferred_delivery_date, :date
    add_column :orders, :preferred_delivery_date_prompt, :string
    add_column :orders, :preferred_delivery_date_format, :string
  end

  def self.down
    remove_column :orders, :preferred_delivery_date_format
    remove_column :orders, :preferred_delivery_date_prompt
    remove_column :orders, :preferred_delivery_date
  end
end
