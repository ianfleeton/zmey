class AddExtraToProducts < ActiveRecord::Migration
  def change
    add_column :products, :extra, :text, limit: 16.megabytes
  end
end
