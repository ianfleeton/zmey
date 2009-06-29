class AddNameAndEmailToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :name, :string, :default => "", :null => false
    add_column :websites, :email, :string, :default => "", :null => false
  end

  def self.down
    remove_column :websites, :email
    remove_column :websites, :name
  end
end
