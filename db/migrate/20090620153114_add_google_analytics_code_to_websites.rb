class AddGoogleAnalyticsCodeToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :google_analytics_code, :string, :default => "", :null => false
  end

  def self.down
    remove_column :websites, :google_analytics_code
  end
end
