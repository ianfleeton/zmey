class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :name, :default => '', :null => false
      t.integer :website_id, :default => 0, :null => false
      t.boolean :locked, :default => false, :null => false
    end
    add_index :forums, :website_id
  end

  def self.down
    drop_table :forums
  end
end
