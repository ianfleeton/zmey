class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.integer :order_id, :default => 0, :null => false
      t.integer :product_id, :default => 0, :null => false
      t.string :product_sku, :default => '', :null => false
      t.string :product_name, :default => '', :null => false
      t.decimal :product_price, :precision => 10, :scale => 3, :default => 0, :null => false
      t.decimal :tax_amount, :precision => 10, :scale => 3, :default => 0, :null => false
      t.integer :quantity, :default => 0, :null => false
      t.decimal :line_total, :precision => 10, :scale => 3, :default => 0, :null => false

      t.timestamps
    end
    add_index :order_lines, :order_id
    add_index :order_lines, :product_id
  end

  def self.down
    drop_table :order_lines
  end
end
