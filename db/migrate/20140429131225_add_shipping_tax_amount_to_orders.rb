class AddShippingTaxAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_tax_amount, :decimal, precision: 10, scale: 3, default: 0.0, null: false
  end
end
