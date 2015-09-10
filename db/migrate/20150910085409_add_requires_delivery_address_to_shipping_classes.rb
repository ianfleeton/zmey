class AddRequiresDeliveryAddressToShippingClasses < ActiveRecord::Migration
  def change
    add_column :shipping_classes, :requires_delivery_address, :boolean, default: true, null: false
  end
end
