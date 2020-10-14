class AddPaidOnToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :paid_on, :date
  end
end
