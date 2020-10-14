class CreateClosureDates < ActiveRecord::Migration[6.0]
  def change
    create_table :closure_dates do |t|
      t.date :closed_on, null: false
      t.boolean :delivery_possible, default: false, null: false

      t.timestamps
    end
  end
end
