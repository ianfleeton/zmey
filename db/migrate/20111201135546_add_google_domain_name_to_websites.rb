class AddGoogleDomainNameToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :google_domain_name, :string, :default => '', :null => false
  end
end
