class RemoveShippingTrackingNumberFromOrders < ActiveRecord::Migration[6.0]
  def change
    remove_column :orders, :shipping_tracking_number
  end
end
