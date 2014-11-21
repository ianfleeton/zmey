class RemoveDefaultBasketIdAndProductIdFromBasketItems < ActiveRecord::Migration
  def up
    change_column_default(:basket_items, :basket_id, nil)
    change_column_default(:basket_items, :product_id, nil)
  end

  def down
    change_column_default(:basket_items, :basket_id, 0)
    change_column_default(:basket_items, :product_id, 0)
  end
end
