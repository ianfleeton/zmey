class AddWebsiteIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :website_id, :integer, :default => 0, :null => false
    add_index :users, :website_id
  end

  def self.down
    remove_column :users, :website_id
  end
end
