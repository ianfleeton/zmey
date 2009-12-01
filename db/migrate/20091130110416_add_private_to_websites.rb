class AddPrivateToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :private, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :private
  end
end
