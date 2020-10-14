class AddDispatchDateToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :dispatch_date, :date
  end
end
