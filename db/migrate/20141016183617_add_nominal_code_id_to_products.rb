class AddNominalCodeIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :nominal_code_id, :integer
    add_index :products, :nominal_code_id
  end
end
