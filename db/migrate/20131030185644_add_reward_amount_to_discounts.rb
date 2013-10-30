class AddRewardAmountToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :reward_amount, :decimal, precision: 10, scale: 3, default: 0, null: false
  end
end
