class AddOversizeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :oversize, :boolean, null: false, default: false
  end
end
