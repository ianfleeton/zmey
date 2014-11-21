class ConvertQuantitiesToDecimal < ActiveRecord::Migration
  def up
    change_column :basket_items, :quantity, :decimal, precision: 10, scale: 3, default: 1, null: false
    change_column :order_lines,  :quantity, :decimal, precision: 10, scale: 3, default: 1, null: false
  end

  def down
    change_column :basket_items, :quantity, :integer, default: 1, null: false
    change_column :order_lines,  :quantity, :integer, default: 0, null: false
  end
end
