class AddLocationToProductGroups < ActiveRecord::Migration
  def change
    add_column :product_groups, :location, :string, default: '', null: false
  end
end
