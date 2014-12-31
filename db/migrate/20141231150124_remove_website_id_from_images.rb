class RemoveWebsiteIdFromImages < ActiveRecord::Migration
  def up
    remove_column :images, :website_id
  end

  def down
    add_column :images, :website_id, null: false, default: 0
  end
end
