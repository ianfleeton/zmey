class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.integer :product_id
      t.string :name, :default => '', :null => false

      t.timestamps
    end
    add_index :attributes, :product_id
  end

  def self.down
    drop_table :attributes
  end
end
