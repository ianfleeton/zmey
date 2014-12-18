class RemoveWebsiteIdFromDiscounts < ActiveRecord::Migration
  def up
    remove_column :discounts, :website_id
  end

  def down
    add_column :discounts, :website_id, null: false
  end
end
