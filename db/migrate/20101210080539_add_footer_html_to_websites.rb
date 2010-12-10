class AddFooterHtmlToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :footer_html, :text, :default => '', :null => false
  end

  def self.down
    remove_column :websites, :footer_html
  end
end
