class AddShippedToOrderLines < ActiveRecord::Migration
  def self.up
    add_column :order_lines, :shipped, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :order_lines, :shipped
  end
end
