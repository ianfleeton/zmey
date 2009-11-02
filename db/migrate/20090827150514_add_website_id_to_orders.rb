class AddWebsiteIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :website_id, :integer, :default => 0, :null => false
    add_index :orders, :website_id
  end

  def self.down
    remove_index :orders, :website_id
    remove_column :orders, :website_id
  end
end
