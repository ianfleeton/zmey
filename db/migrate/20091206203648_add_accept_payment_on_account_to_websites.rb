class AddAcceptPaymentOnAccountToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :accept_payment_on_account, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :accept_payment_on_account
  end
end
