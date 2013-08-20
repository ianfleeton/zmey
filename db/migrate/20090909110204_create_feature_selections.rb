class CreateFeatureSelections < ActiveRecord::Migration
  def self.up
    create_table :feature_selections do |t|
      t.integer :basket_item_id, :default => 0, :null => false
      t.integer :feature_id, :default => 0, :null => false
      t.integer :choice_id
      t.text :customer_text
      t.boolean :checked, :default => false, :null => false

      t.timestamps
    end
    add_index :feature_selections, :basket_item_id
  end

  def self.down
    drop_table :feature_selections
  end
end
