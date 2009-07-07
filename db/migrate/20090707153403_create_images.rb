class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :website_id, :default => 0, :null => false
      t.string :name, :default => '', :null => false
      t.string :filename, :default => '', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
