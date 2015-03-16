class AddShippingTrackingNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_tracking_number, :string
  end
end
