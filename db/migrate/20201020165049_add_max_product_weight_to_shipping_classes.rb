class AddMaxProductWeightToShippingClasses < ActiveRecord::Migration[6.0]
  def change
    add_column :shipping_classes, :max_product_weight, :integer, default: 0, null: false
  end
end
