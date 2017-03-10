class RemoveNominalCodes < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :purchase_nominal_code_id
    remove_column :products, :sales_nominal_code_id
    drop_table :nominal_codes
  end
end
