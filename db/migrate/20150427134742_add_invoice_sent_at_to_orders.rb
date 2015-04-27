class AddInvoiceSentAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_sent_at, :datetime
  end
end
