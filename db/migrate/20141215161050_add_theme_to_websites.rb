class AddThemeToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :theme, :string
  end
end
