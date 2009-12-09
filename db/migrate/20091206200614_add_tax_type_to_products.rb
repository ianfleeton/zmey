class AddTaxTypeToProducts < ActiveRecord::Migration
  def self.up
    # Default 1 = Product::NO_TAX
    add_column :products, :tax_type, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :products, :tax_type
  end
end
