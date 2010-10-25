class CreateShippingClasses < ActiveRecord::Migration
  def self.up
    create_table :shipping_classes do |t|
      t.integer :shipping_zone_id, :default => 0, :null => false
      t.string :name, :default => '', :null => false

      t.timestamps
    end
    add_index :shipping_classes, :shipping_zone_id
  end

  def self.down
    drop_table :shipping_classes
  end
end
