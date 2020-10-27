class RemovePreferredDeliveryDate < ActiveRecord::Migration[6.0]
  def change
    remove_column :orders, :preferred_delivery_date
    remove_column :orders, :preferred_delivery_date_prompt
    remove_column :orders, :preferred_delivery_date_format
    drop_table :preferred_delivery_date_settings
  end
end
