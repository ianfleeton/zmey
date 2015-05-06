class AddStagingPasswordToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :staging_password, :string
  end
end
