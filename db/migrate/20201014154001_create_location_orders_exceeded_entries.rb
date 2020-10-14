class CreateLocationOrdersExceededEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :location_orders_exceeded_entries do |t|
      t.references :location, null: false, foreign_key: true
      t.date :exceeded_on, null: false

      t.timestamps
    end
  end
end
