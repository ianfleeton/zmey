class AddProductWeightToOrderLines < ActiveRecord::Migration
  def change
    add_column :order_lines, :product_weight, :decimal, precision: 10, scale: 3, default: 0.0, null: false
  end
end
