class AddWebsiteIdToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :website_id, :integer, :default => 0, :null => false
    add_index :countries, :website_id
  end

  def self.down
    remove_column :countries, :website_id
  end
end
