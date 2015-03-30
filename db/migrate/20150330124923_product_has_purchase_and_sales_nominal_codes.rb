class ProductHasPurchaseAndSalesNominalCodes < ActiveRecord::Migration
  def up
    remove_column :products, :nominal_code_id
    add_column :products, :purchase_nominal_code_id, :integer
    add_column :products, :sales_nominal_code_id, :integer
    add_index :products, :purchase_nominal_code_id
    add_index :products, :sales_nominal_code_id
  end

  def down
    add_column :products, :nominal_code_id, :integer
    add_index :products, :nominal_code_id
    remove_column :products, :purchase_nominal_code_id
    remove_column :products, :sales_nominal_code_id
  end
end
