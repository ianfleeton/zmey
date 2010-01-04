class AddBlogIdToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :blog_id, :integer, :default => nil, :null => true
  end

  def self.down
    remove_column :websites, :blog_id
  end
end
