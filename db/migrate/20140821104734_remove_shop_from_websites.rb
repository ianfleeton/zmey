class RemoveShopFromWebsites < ActiveRecord::Migration
  def up
    remove_column :websites, :shop
  end

  def down
    add_column :websites, :shop, :boolean, default: false, null: false
  end
end
