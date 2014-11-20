class AddSmtpSettingsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :smtp_active,   :boolean, default: false, null: false
    add_column :websites, :smtp_host,     :string,  default: '',    null: false
    add_column :websites, :smtp_username, :string,  default: '',    null: false
    add_column :websites, :smtp_password, :string,  default: '',    null: false
    add_column :websites, :smtp_port,     :integer, default: 25,    null: false
  end
end
