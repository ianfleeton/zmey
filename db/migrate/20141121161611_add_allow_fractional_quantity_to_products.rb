class AddAllowFractionalQuantityToProducts < ActiveRecord::Migration
  def change
    add_column :products, :allow_fractional_quantity, :boolean, default: false, null: false
  end
end
