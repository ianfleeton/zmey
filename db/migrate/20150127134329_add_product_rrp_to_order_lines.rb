class AddProductRrpToOrderLines < ActiveRecord::Migration
  def change
    add_column :order_lines, :product_rrp, :decimal, precision: 10, scale: 3
  end
end
