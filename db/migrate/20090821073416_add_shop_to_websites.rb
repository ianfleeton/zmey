class AddShopToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :shop, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :shop
  end
end
