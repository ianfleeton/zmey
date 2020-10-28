class AddCourierIdToShipments < ActiveRecord::Migration[6.0]
  def change
    add_reference :shipments, :courier, null: false, foreign_key: true
  end
end
