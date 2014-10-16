class CreateNominalCodes < ActiveRecord::Migration
  def change
    create_table :nominal_codes do |t|
      t.integer :website_id, null: false
      t.string :code, null: false
      t.string :description, null: false

      t.timestamps null: false
    end
    add_index :nominal_codes, :website_id
    add_index :nominal_codes, :code
  end
end
