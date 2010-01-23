class AddShowVatInclusivePricesToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :show_vat_inclusive_prices, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :show_vat_inclusive_prices
  end
end
