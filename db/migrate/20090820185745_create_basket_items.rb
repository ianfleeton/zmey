class CreateBasketItems < ActiveRecord::Migration
  def self.up
    create_table :basket_items do |t|
      t.integer :basket_id, :default => 0, :null => false
      t.integer :product_id, :default => 0, :null => false
      t.integer :quantity, :default => 1, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :basket_items
  end
end
