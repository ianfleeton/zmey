class RemoveWebsiteIdFromProductGroups < ActiveRecord::Migration
  def up
    remove_column :product_groups, :website_id
  end

  def down
    add_column :product_groups, :website_id, :integer
  end
end
