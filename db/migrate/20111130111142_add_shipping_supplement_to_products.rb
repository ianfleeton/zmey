class AddShippingSupplementToProducts < ActiveRecord::Migration
  def change
    add_column :products, :shipping_supplement, :decimal, :precision => 10, :scale => 3, :default => 0, :null => false
  end
end
