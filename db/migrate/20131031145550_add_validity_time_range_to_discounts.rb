class AddValidityTimeRangeToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :valid_from, :datetime
    add_column :discounts, :valid_to, :datetime
  end
end
