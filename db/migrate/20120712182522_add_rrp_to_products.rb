class AddRrpToProducts < ActiveRecord::Migration
  def change
    add_column :products, :rrp, :decimal, precision: 10, scale: 3
  end
end
