class RenameOrdersShippingTaxAmountToVatAmount < ActiveRecord::Migration[6.1]
  def change
    rename_column :orders, :shipping_tax_amount, :shipping_vat_amount
  end
end
