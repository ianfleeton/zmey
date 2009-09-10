class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.integer :product_id
      t.string :name, :default => '', :null => false

      t.timestamps
    end
    add_index :features, :product_id
  end

  def self.down
    drop_table :features
  end
end
