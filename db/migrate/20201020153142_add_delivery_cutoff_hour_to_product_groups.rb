class AddDeliveryCutoffHourToProductGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :product_groups, :delivery_cutoff_hour, :integer, default: 0, null: false
  end
end
