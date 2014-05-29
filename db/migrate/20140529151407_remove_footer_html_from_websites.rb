class RemoveFooterHtmlFromWebsites < ActiveRecord::Migration
  def self.up
    remove_column :websites, :footer_html
  end

  def self.down
    add_column :websites, :footer_html, :text
  end
end
