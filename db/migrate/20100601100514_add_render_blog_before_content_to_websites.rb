class AddRenderBlogBeforeContentToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :render_blog_before_content, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :websites, :render_blog_before_content
  end
end
