class AddVatNumberToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :vat_number, :string, :default => '', :null => false
  end

  def self.down
    remove_column :websites, :vat_number
  end
end
