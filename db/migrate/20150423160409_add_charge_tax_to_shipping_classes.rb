class AddChargeTaxToShippingClasses < ActiveRecord::Migration
  def change
    add_column :shipping_classes, :charge_tax, :boolean, default: true, null: false
  end
end
