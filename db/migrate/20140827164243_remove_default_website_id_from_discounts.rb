class RemoveDefaultWebsiteIdFromDiscounts < ActiveRecord::Migration
  def up
    change_column_default(:discounts, :website_id, nil)
  end

  def down
    change_column_default(:discounts, :website_id, 0)
  end
end
