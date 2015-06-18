class AddSalesConversionRecordedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sales_conversion_recorded_at, :datetime, null: true, default: nil
  end
end
