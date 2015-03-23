class RemoveWebsiteIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :website_id
  end

  def down
    add_column :users, :website_id, default: 0, null: false
    add_index :users, :website_id
  end
end
