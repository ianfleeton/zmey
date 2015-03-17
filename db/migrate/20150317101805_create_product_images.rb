class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :product_id, null: false
      t.integer :image_id, null: false

      t.timestamps null: false
    end

    add_index :product_images, :product_id
    add_index :product_images, :image_id
  end
end
