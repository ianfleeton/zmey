class CreateShippingZones < ActiveRecord::Migration
  def self.up
    create_table :shipping_zones do |t|
      t.integer :website_id, :default => 0, :null => false
      t.string :name, :default => '', :null => false

      t.timestamps
    end
    add_column :countries, :shipping_zone_id, :integer
  end

  def self.down
    remove_column :countries, :shipping_zone_id
    drop_table :shipping_zones
  end
end
