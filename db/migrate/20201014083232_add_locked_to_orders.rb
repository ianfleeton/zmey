class AddLockedToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :locked, :boolean, null: false, default: false
  end
end
