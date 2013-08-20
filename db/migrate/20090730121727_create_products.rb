class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :website_id
      t.string :sku, :default => '', :null => false
      t.string :name, :default => '', :null => false
      t.decimal :price, :precision => 10, :scale => 3, :default => 0, :null => false
      t.integer :image_id
      t.text :description
      t.boolean :in_stock, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
