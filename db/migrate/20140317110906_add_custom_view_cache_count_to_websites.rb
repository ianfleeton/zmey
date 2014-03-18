class AddCustomViewCacheCountToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :custom_view_cache_count, :integer, null: false, default: 0
  end
end
