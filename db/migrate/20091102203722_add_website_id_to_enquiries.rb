class AddWebsiteIdToEnquiries < ActiveRecord::Migration
  def self.up
    add_column :enquiries, :website_id, :integer, :default => 0, :null => false
    add_index :enquiries, :website_id
  end

  def self.down
    remove_index :enquiries, :website_id
    remove_column :enquiries, :website_id
  end
end
