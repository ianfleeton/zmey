class CreatePermutations < ActiveRecord::Migration
  def change
    create_table :permutations do |t|
      t.integer :component_id, null: false
      t.string :permutation, null: false
      t.boolean :valid_selection, null: false
      t.decimal :price, precision: 10, scale: 3, default: 0, null: false
      t.decimal :weight, precision: 10, scale: 3, default: 0, null: false

      t.timestamps
    end

    add_index :permutations, :component_id
    add_index :permutations, :permutation
  end
end
