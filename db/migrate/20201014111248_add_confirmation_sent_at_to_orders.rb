class AddConfirmationSentAtToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :confirmation_sent_at, :datetime
  end
end
