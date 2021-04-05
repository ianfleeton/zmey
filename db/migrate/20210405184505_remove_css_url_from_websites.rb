class RemoveCssUrlFromWebsites < ActiveRecord::Migration[6.1]
  def change
    remove_column :websites, :css_url
  end
end
