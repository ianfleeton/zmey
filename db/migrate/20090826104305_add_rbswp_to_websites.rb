class AddRbswpToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :rbswp_active, :boolean, :default => false, :null => false
    add_column :websites, :rbswp_installation_id, :string, :default => '', :null => false
    add_column :websites, :rbswp_payment_response_password, :string, :default => '', :null => false
    add_column :websites, :rbswp_test_mode, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :rbswp_test_mode
    remove_column :websites, :rbswp_payment_response_password
    remove_column :websites, :rbswp_installation_id
    remove_column :websites, :rbswp_active
  end
end
