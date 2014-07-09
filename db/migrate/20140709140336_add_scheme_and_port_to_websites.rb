class AddSchemeAndPortToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :scheme, :string, default: 'http', null: false
    add_column :websites, :port, :integer, default: 80, null: false
  end
end
