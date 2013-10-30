class RemoveLineTotalFromOrderLines < ActiveRecord::Migration
  def up
    remove_column :order_lines, :line_total
  end

  def down
    add_column :order_lines, :line_total, :decimal, precision: 10, scale: 3, default: 0, null: false
  end
end
