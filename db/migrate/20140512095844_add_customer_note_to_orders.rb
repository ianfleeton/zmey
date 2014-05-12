class AddCustomerNoteToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_note, :text
  end
end
