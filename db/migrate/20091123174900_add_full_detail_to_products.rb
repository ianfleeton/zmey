class AddFullDetailToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :full_detail, :text
  end

  def self.down
    remove_column :products, :full_detail
  end
end
