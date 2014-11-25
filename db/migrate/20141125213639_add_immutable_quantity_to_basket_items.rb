class AddImmutableQuantityToBasketItems < ActiveRecord::Migration
  def change
    add_column :basket_items, :immutable_quantity, :boolean, default: false, null: false
  end
end
