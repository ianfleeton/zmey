class AddWeightToProducts < ActiveRecord::Migration
  def change
    add_column :products, :weight, :decimal, precision: 10, scale: 3, default: 0, null: false
  end
end
