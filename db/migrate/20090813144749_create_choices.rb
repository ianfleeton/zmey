class CreateChoices < ActiveRecord::Migration
  def self.up
    create_table :choices do |t|
      t.integer :feature_id, :default => 0, :null => false
      t.string :name

      t.timestamps
    end
    add_index :choices, :feature_id
  end

  def self.down
    drop_table :choices
  end
end
