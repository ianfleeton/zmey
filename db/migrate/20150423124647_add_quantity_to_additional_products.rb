class AddQuantityToAdditionalProducts < ActiveRecord::Migration
  def change
    add_column :additional_products, :quantity, :integer, default: 1, null: false
  end
end
