class RemoveWebsiteIdFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :website_id
  end

  def down
    add_column :orders, :website_id, :integer, default: 0, null: false
    add_index :orders, :website_id
  end
end
