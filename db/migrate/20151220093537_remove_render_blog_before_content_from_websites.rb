class RemoveRenderBlogBeforeContentFromWebsites < ActiveRecord::Migration
  def up
    remove_column :websites, :render_blog_before_content
  end

  def down
    add_column :websites, :render_blog_before_content, :boolean, default: true, null: false
  end
end
