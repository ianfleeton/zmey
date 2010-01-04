class CreateQuantityPrices < ActiveRecord::Migration
  def self.up
    create_table :quantity_prices do |t|
      t.integer :product_id
      t.integer :quantity, :default => 0, :null => false
      t.decimal :price, :precision => 10, :scale => 3, :default => 0, :null => false

      t.timestamps
    end
    add_index :quantity_prices, :product_id
  end

  def self.down
    drop_table :quantity_prices
  end
end
