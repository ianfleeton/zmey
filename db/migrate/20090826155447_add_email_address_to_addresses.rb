class AddEmailAddressToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :email_address, :string, :default => '', :null => false
  end

  def self.down
    remove_column :addresses, :email_address
  end
end
