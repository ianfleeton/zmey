class AddDefaultShippingClassIdToShippingZones < ActiveRecord::Migration
  def change
    add_column :shipping_zones, :default_shipping_class_id, :integer
  end
end
