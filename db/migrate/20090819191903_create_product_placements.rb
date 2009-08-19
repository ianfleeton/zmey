class CreateProductPlacements < ActiveRecord::Migration
  def self.up
    create_table :product_placements do |t|
      t.integer :page_id, :default => 0, :null => false
      t.integer :product_id, :default => 0, :null => false
      t.integer :position, :default => 0, :null => false

      t.timestamps
    end
    add_index :product_placements, :page_id
    add_index :product_placements, :product_id
  end

  def self.down
    drop_table :product_placements
  end
end
