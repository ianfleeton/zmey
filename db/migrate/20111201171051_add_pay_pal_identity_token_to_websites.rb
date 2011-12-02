class AddPayPalIdentityTokenToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :paypal_identity_token, :string, :default => '', :null => false
  end
end
