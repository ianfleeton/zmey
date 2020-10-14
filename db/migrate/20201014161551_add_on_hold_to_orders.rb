class AddOnHoldToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :on_hold, :boolean, default: false, null: false
  end
end
