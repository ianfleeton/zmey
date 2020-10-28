class CreateCouriers < ActiveRecord::Migration[6.0]
  def change
    create_table :couriers do |t|
      t.string :name, null: false
      t.string :account_number
      t.string :tracking_url
      t.boolean :generate_consignment_number, default: false, null: false
      t.string :consignment_prefix

      t.timestamps
    end
  end
end
