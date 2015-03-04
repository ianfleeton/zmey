class CreateRelatedProductScores < ActiveRecord::Migration
  def change
    create_table :related_product_scores do |t|
      t.integer :product_id, null: false
      t.integer :related_product_id, null: false
      t.decimal :score, precision: 4, scale: 3, null: false

      t.timestamps null: false
    end
    add_index :related_product_scores, :product_id
  end
end
