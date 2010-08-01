class CreateProductGroups < ActiveRecord::Migration
  def self.up
    create_table :product_groups do |t|
      t.integer :website_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :product_groups
  end
end
