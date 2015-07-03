class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :order_id, null: false
      t.string :courier_name
      t.string :tracking_number
      t.string :tracking_url
      t.string :picked_by
      t.integer :number_of_parcels, null: false, default: 1
      t.decimal :total_weight, precision: 10, scale: 3, null: false, default: 0
      t.datetime :shipped_at
      t.boolean :partial, null: false, default: false
      t.datetime :email_sent_at
      t.text :comment

      t.timestamps null: false
    end
  end
end
