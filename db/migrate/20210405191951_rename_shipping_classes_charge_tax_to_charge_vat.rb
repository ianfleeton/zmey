class RenameShippingClassesChargeTaxToChargeVat < ActiveRecord::Migration[6.1]
  def change
    rename_column :shipping_classes, :charge_tax, :charge_vat
  end
end
