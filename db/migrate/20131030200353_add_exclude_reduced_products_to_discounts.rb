class AddExcludeReducedProductsToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :exclude_reduced_products, :boolean, default: true, null: false
  end
end
