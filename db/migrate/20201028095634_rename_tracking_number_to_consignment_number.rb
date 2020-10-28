class RenameTrackingNumberToConsignmentNumber < ActiveRecord::Migration[6.0]
  def change
    rename_column :shipments, :tracking_number, :consignment_number
  end
end
