class RenameOrderLinesTaxAmountToVatAmount < ActiveRecord::Migration[6.1]
  def change
    rename_column :order_lines, :tax_amount, :vat_amount
  end
end
