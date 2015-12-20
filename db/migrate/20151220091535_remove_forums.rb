class RemoveForums < ActiveRecord::Migration
  def change
    drop_table :forums
    remove_column :websites, :blog_id
  end
end
