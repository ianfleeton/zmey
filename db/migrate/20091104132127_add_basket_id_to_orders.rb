class AddBasketIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :basket_id, :integer, :default => nil, :null => true
    add_index :orders, :basket_id
  end

  def self.down
    remove_index :orders, :basket_id
    remove_column :orders, :basket_id
  end
end
