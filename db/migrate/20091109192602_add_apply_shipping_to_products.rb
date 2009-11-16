class AddApplyShippingToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :apply_shipping, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :products, :apply_shipping
  end
end
