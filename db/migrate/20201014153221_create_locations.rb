class CreateLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.integer :max_daily_orders, default: 0, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
