class AddRequiresDeliveryAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :requires_delivery_address, :boolean, default: true, null: false
  end
end
