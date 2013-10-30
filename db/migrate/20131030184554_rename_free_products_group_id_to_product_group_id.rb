class RenameFreeProductsGroupIdToProductGroupId < ActiveRecord::Migration
  def change
    rename_column :discounts, :free_products_group_id, :product_group_id
  end
end
