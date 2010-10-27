class CreateShippingTableRows < ActiveRecord::Migration
  def self.up
    create_table :shipping_table_rows do |t|
      t.integer :shipping_class_id, :default => 0, :null => false
      t.decimal :trigger_value, :precision => 10, :scale => 3, :default => 0, :null => false
      t.decimal :amount, :precision => 10, :scale => 3, :default => 0, :null => false

      t.timestamps
    end
    add_index :shipping_table_rows, :shipping_class_id
  end

  def self.down
    drop_table :shipping_table_rows
  end
end
