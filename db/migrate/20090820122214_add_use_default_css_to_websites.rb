class AddUseDefaultCssToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :use_default_css, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :use_default_css
  end
end
