class AddProcessedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :processed_at, :datetime
    add_index :orders, :processed_at
  end
end
