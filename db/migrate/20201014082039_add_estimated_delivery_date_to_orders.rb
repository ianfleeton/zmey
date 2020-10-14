class AddEstimatedDeliveryDateToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :estimated_delivery_date, :date
  end
end
