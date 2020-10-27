class AddRewardToBasketItems < ActiveRecord::Migration[6.0]
  def change
    add_column :basket_items, :reward, :boolean, null: false, default: false
  end
end
