class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name, null: false
      t.integer :product_id, null: false

      t.timestamps
    end

    add_index :components, :product_id
  end
end
