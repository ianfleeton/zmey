class AddGoogleFtpDetailsToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :google_ftp_username, :string, :default => '', :null => false
    add_column :websites, :google_ftp_password, :string, :default => '', :null => false
  end

  def self.down
    remove_column :websites, :google_ftp_password
    remove_column :websites, :google_ftp_username
  end
end
