class RemoveDefaultManagesWebsiteIdFromUsers < ActiveRecord::Migration
  def up
    change_column_default(:users, :manages_website_id, nil)
    change_column_null(:users, :manages_website_id, true)
  end

  def down
    change_column_default(:users, :manages_website_id, 0)
    change_column_null(:users, :manages_website_id, false)
  end
end
