class RemoveCourierNameFromShipments < ActiveRecord::Migration[6.0]
  def change
    remove_column :shipments, :courier_name
  end
end
