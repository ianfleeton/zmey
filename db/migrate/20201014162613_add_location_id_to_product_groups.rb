class AddLocationIdToProductGroups < ActiveRecord::Migration[6.0]
  def change
    remove_column :product_groups, :location
    add_reference :product_groups, :location, null: true, foreign_key: true
  end
end
