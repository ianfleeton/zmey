class AddShippingAmountToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :shipping_amount, :decimal, :precision => 10, :scale => 3, :default => 0, :null => false
  end

  def self.down
    remove_column :websites, :shipping_amount
  end
end
