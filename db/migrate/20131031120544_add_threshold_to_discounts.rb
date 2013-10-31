class AddThresholdToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :threshold, :decimal, precision: 10, scale: 3, default: 0, null: false
  end
end
