class AddCanUsersCreateAccountsToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :can_users_create_accounts, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :websites, :can_users_create_accounts
  end
end
