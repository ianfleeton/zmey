class CreateAdditionalProducts < ActiveRecord::Migration
  def change
    create_table :additional_products do |t|
      t.integer :product_id, :null => false
      t.integer :additional_product_id, :null => false
      t.boolean :selected_by_default, :default => false, :null => false

      t.timestamps
    end
    add_index :additional_products, :product_id
  end
end
