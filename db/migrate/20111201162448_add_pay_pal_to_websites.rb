class AddPayPalToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :paypal_active, :boolean, :default => false, :null => false
    add_column :websites, :paypal_email_address, :string, :default => '', :null => false
  end
end
