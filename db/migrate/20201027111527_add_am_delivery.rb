class AddAmDelivery < ActiveRecord::Migration[6.0]
  def change
    add_column :baskets, :am_delivery, :boolean, default: false, null: false
    add_column :orders, :am_delivery, :boolean, default: false, null: false
    add_column :shipping_classes, :allows_am_delivery, :boolean, default: false, null: false
  end
end
