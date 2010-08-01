class CreateProductGroupPlacements < ActiveRecord::Migration
  def self.up
    create_table :product_group_placements do |t|
      t.integer :product_id, :default => 0, :null => false
      t.integer :product_group_id, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :product_group_placements
  end
end
