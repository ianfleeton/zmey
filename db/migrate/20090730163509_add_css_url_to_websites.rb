class AddCssUrlToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :css_url, :text, :default => '', :null => false
  end

  def self.down
    remove_column :websites, :css_url
  end
end
