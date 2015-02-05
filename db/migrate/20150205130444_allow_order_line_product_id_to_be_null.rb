class AllowOrderLineProductIdToBeNull < ActiveRecord::Migration
  def up
    change_column :order_lines, :product_id, :integer, default: nil, null: true
  end

  def down
    change_column :order_lines, :product_id, :integer, default: 0, null: false
  end
end
