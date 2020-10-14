class AddInvoicedAtToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :invoiced_at, :datetime
  end
end
