class RemoveAdminAndManagesWebsiteIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :admin
    remove_column :users, :manages_website_id
  end
end
